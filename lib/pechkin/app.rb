module Pechkin
  # Application configurator and builder. This creates all needed middleware
  # and stuff
  class AppBuilder
    def build(handler, options)
      app = App.new
      app.handler = handler
      prometheus = Pechkin::PrometheusUtils.registry
      logger = create_logger(options.log_dir)

      Rack::Builder.app do
        use Rack::CommonLogger, logger
        use Rack::Deflater
        use Prometheus::Middleware::Collector, registry: prometheus
        # Add Auth check if found htpasswd file or it was excplicitly provided
        # See CLI class for configuration details
        if options.htpasswd
          use Pechkin::Auth::Middleware, auth_file: options.htpasswd
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
    attr_accessor :handler

    def call(env)
      RequestHandler.new(handler, env).handle
    rescue StandardError => e
      body = { status: 'error', reason: e.message }.to_json
      ['503', { 'Content-Type' => 'application/json' }, [body]]
    end
  end

  # Http requests handler. We need fresh instance per each request. To keep
  # internal state isolated
  class RequestHandler
    REQ_PATH_PATTERN = %r{^/(.+)/([^/]+)/?$}
    DEFAULT_CONTENT_TYPE = { 'Content-Type' => 'application/json' }.freeze
    DEFAULT_HEADERS = {}.merge(DEFAULT_CONTENT_TYPE).freeze

    attr_reader :req, :env, :handler,
                :channel_id, :message_id

    def initialize(handler, env)
      @handler = handler
      @env = env
      @req = Rack::Request.new(env)

      @channel_id, @message_id = req.path_info.match(REQ_PATH_PATTERN) do |m|
        [m[1], m[2]]
      end
    end

    def handle
      return not_allowed unless post?
      return not_found unless message?

      begin
        data = JSON.parse(req.body.read)
      rescue JSON::JSONError => e
        return bad_request(e.message)
      end

      response(200, handler.handle(channel_id, message_id, data).to_json)
    end

    private

    def message?
      return false unless @channel_id && @message_id

      handler.message?(@channel_id, @message_id)
    end

    def not_allowed
      response(405, '{"status":"error", "reason":"method not allowed"}')
    end

    def not_found
      response(404, '{"status":"error", "reason":"message not found"}')
    end

    def bad_request(body)
      response(503, body)
    end

    def response(code, body)
      [code.to_s, DEFAULT_HEADERS, [body]]
    end

    def post?
      req.post?
    end
  end
end
