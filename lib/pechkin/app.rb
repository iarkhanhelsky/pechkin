module Pechkin
  # Generic application error class.
  #
  # Allows us return meaningful error messages
  class AppError < StandardError
    attr_reader :code

    def initialize(code, msg)
      super(msg)
      @code = code
    end

    class << self
      def bad_request(message)
        AppError.new(503, message)
      end

      def message_not_found
        AppError.new(404, 'message not found')
      end

      def http_method_not_allowed
        AppError.new(405, 'method not allowed')
      end
    end
  end
  # Application configurator and builder. This creates all needed middleware
  # and stuff
  class AppBuilder
    def build(handler, options)
      logger = create_logger(options.log_dir)
      app = App.new(logger)
      app.handler = handler
      prometheus = Pechkin::PrometheusUtils.registry

      Rack::Builder.app do
        use Rack::CommonLogger, logger
        use Rack::Deflater
        use Prometheus::Middleware::Collector, registry: prometheus
        # Add Auth check if found htpasswd file or it was excplicitly provided
        # See CLI class for configuration details
        if options.htpasswd
          use Pechkin::Auth::Middleware, auth_file: options.htpasswd,
                                         logger: logger
        end
        use Prometheus::Middleware::Exporter, registry: prometheus

        run app
      end
    end

    private

    def create_logger(log_dir)
      if log_dir
        raise "Directory #{log_dir} does not exist" unless File.exist?(log_dir)

        log_file = File.join(log_dir, 'pechkin.log')
        file = File.open(log_file, File::WRONLY | File::APPEND)
        Logger.new(file)
      else
        Logger.new(STDOUT)
      end
    end
  end

  # Rack application to handle requests
  class App
    DEFAULT_CONTENT_TYPE = { 'Content-Type' => 'application/json' }.freeze
    DEFAULT_HEADERS = {}.merge(DEFAULT_CONTENT_TYPE).freeze

    attr_accessor :handler, :logger

    def initialize(logger)
      @logger = logger
    end

    def call(env)
      req = Rack::Request.new(env)
      result = RequestHandler.new(handler, req, logger).handle
      response(200, result)
    rescue AppError => e
      proces_app_error(req, e)
    rescue StandardError => e
      process_unhandled_error(req, e)
    end

    private

    def response(code, body)
      [code.to_s, DEFAULT_HEADERS, [body.to_json]]
    end

    def proces_app_error(req, err)
      data = { status: 'error', message: err.message }
      req.body.rewind
      body = req.body.read
      logger.error "Can't process message: #{err.message}. Body: '#{body}'"
      response(err.code, data)
    end

    def process_unhandled_error(_req, err)
      data = { status: 'error', message: err.message }
      logger.error("#{err.message}\n\t" + err.backtrace.join("\n\t"))
      response(503, data)
    end
  end

  # Http requests handler. We need fresh instance per each request. To keep
  # internal state isolated
  class RequestHandler
    REQ_PATH_PATTERN = %r{^/(.+)/([^/]+)/?$}

    attr_reader :req, :handler,
                :channel_id, :message_id,
                :logger

    def initialize(handler, req, logger)
      @handler = handler
      @req = req
      @logger = logger

      @channel_id, @message_id = req.path_info.match(REQ_PATH_PATTERN) do |m|
        [m[1], m[2]]
      end
    end

    def handle
      raise AppError.http_method_not_allowed unless post?
      raise AppError.message_not_found unless message?

      data = parse_data(req.body.read)
      handler.handle(channel_id, message_id, data).each do |i|
        logger.info "Sent #{channel_id}/#{message_id}: #{i.to_json}"
      end
    end

    private

    def parse_data(data)
      JSON.parse(data)
    rescue JSON::JSONError => e
      raise AppError.bad_request(e.message)
    end

    def message?
      return false unless @channel_id && @message_id

      handler.message?(@channel_id, @message_id)
    end

    def post?
      req.post?
    end
  end
end
