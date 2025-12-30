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
        AppError.new(400, message)
      end

      def message_not_found
        AppError.new(404, 'message not found')
      end

      def http_method_not_allowed
        AppError.new(405, 'method not allowed')
      end
    end
  end
end
