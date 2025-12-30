require_relative '../version'

module Pechkin
  # Rack application to handle requests
  class App
    DEFAULT_CONTENT_TYPE = { 'Content-Type' => 'application/json' }.freeze
    DEFAULT_HEADERS = {}.merge(DEFAULT_CONTENT_TYPE)

    attr_accessor :handler, :logger

    def initialize(logger)
      @logger = logger
    end

    def call(env)
      req = Rack::Request.new(env)

      # Stub for favicon.ico
      if req.path_info == '/favicon.ico'
        response(405, message: 'Method Not Allowed') # Return empty response 405 Method Not Allowed
      elsif req.path_info == '/health'
        response(200, { status: 'ok', message: 'Pechkin is running', version: Pechkin::Version.version_string })
      else
        result = RequestHandler.new(handler, req, logger).handle
        response(200, result)
      end
    rescue AppError => e
      process_app_error(req, e)
    rescue StandardError => e
      process_unhandled_error(req, e)
    end

    private

    def response(code, body)
      [code, DEFAULT_HEADERS.dup, [body.to_json]]
    end

    def process_app_error(req, err)
      data = { status: 'error', message: err.message }
      if req.body
        req.body.rewind
        body = req.body.read
      else
        body = ''
      end

      logger.error "Can't process message: #{err.message}. Body: '#{body}'"
      response(err.code, data)
    end

    def process_unhandled_error(req, err)
      data = { status: 'error', message: err.message }
      logger.error("#{err.message}\n\t" + err.backtrace.join("\n\t"))
      logger.error(req.body.read)
      response(503, data)
    end
  end
end
