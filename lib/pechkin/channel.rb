module Pechkin
  # Creates object which can send messages to assigned chanels
  class Chanel
    attr_accessor :logger

    def initialize(connector, channel_list)
      @connector = connector
      @channel_list = channel_list
      @channel_list = [channel_list] unless channel_list.is_a?(Array)
      @logger = ::Logger.new(STDOUT)
    end

    def send_message(message, data, options)
      text = Message.new(data).render(message)
      logger.warn 'Resulting text is empty' if text.empty?
      results = @channel_list.map { |id| @connector.send_message(id, text, options) }
      process_results(message, results)
    end

    private

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
