module Pechkin
  # Creates object which can send messages to assigned chanels
  class Chanel
    attr_accessor :logger

    def initialize(connector, channel_list, logger = ::Logger.new(STDOUT))
      @connector = connector
      @channel_list = channel_list
      @channel_list = [channel_list] unless channel_list.is_a?(Array)
      @logger = logger
    end

    def send_message(message, data, message_desc)
      text = message.nil? ? '' : Message.new(data).render(message)

      message_desc = substitute(data, message_desc)

      logger.warn 'Resulting text is empty' if text.empty?
      results = @channel_list.map do |id|
        @connector.send_message(id, text, message_desc)
      end

      process_results(message, results)
    end

    private

    def substitute(data, message_desc)
      substitute_recursive(Substitute.new(data), message_desc)
    end

    def substitute_recursive(substitutions, object)
      case object
      when String
        substitutions.process(object)
      when Array
        object.map { |o| substitute_recursive(substitutions, o) }
      when Hash
        r = {}
        object.each { |k, v| r[k] = substitute_recursive(substitutions, v) }
        r
      else
        object
      end
    end

    def process_results(message, results)
      success, error = results.partition { |_chat, code, _body| code < 400 }
      error.each do |chat, code, body|
        logger.error "#{message} => #{chat}[HTTP #{code}]: #{body}"
      end

      {
        successful: success.map(&:first),
        errors: error
      }
    end
  end
end
