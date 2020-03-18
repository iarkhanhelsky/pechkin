module Pechkin
  module Connector
    class Telegram < Connector::Base # :nodoc:
      attr_reader :name

      def initialize(bot_token, name)
        @bot_token = bot_token
        @name = name
      end

      def send_message(chat_id, message, message_desc)
        options = { parse_mode: message_desc['telegram_parse_mode'] || 'HTML' }
        params = options.update(chat_id: chat_id, text: message)

        response = post_data(method_url('sendMessage'), params)
        { chat_id: chat_id, code: response.code.to_i, response: response.body }
      end

      private

      def method_url(method)
        "https://api.telegram.org/bot#{@bot_token}/#{method}"
      end
    end
  end
end
