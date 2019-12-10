require 'json'

module Pechkin # :nodoc:
  # Pechkin WEB Api handler. It responsible for parsing http requests and
  # prepare all needed data for Pechkin::Handler to process it.
  class HttpHandler
    attr_accessor :handler

    def call(env)
      HttpRequestHandler.new(handler, env).handle
    rescue StandardError => e
      body = '{"status": "error", "reason":"' + e.message + '"'
      ['503', { 'Content-Type' => 'application/json' }, body]
    end
  end

  class HttpRequestHandler # :nodoc:
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
        data = JSON.parse(req.body.read, symbolize_names: true)
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

    def response(code, body)
      [code.to_s, DEFAULT_HEADERS, body]
    end

    def post?
      req.post?
    end
  end
end
