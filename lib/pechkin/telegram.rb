require 'erb'
require 'open-uri'
require 'net/http'

module Pechkin
  module Telegram
    # Easy way to render erb template
    class Message < OpenStruct
      def render(template_file)
        ERB.new(IO.read(template_file)).result(binding)
      end
    end
    # Creates object which can send messages to assigned chanels
    class Chanel
      attr_accessor :logger

      def initialize(bot_token, chat_ids)
        @bot_token = bot_token
        @chat_ids = chat_ids
        @chat_ids = [chat_ids] unless chat_ids.is_a?(Array)
        @logger = ::Logger.new(STDOUT)
      end

      def send_message(message, data, options)
        text = Message.new(data).render(message)
        logger.warn 'Resulting text is empty' if text.empty?
        results = @chat_ids.map { |id| send_message_to_id(id, text, options) }
        process_results(message, results)
      end

      private

      def send_message_to_id(chat_id, text, options)
        params = options.update(text: text, chat_id: chat_id)
        response = send_data('sendMessage', params)
        [chat_id, response.code.to_i, response.body]
      end

      def send_data(method, data = {})
        url = URI.parse(method_url(method))
        Net::HTTP.post_form(url, data)
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

      def method_url(method)
        "https://api.telegram.org/bot#{@bot_token}/#{method}"
      end
    end
  end
end
