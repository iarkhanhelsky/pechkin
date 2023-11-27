module Pechkin
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
      # handler.handle() requires keyword arguments
      handler.handle(channel_id, message_id, **data).each do |i|
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
