module Pechkin
  class TelegramConnector < Connector #:nodoc:
    def initialize(bot_token)
      @bot_token = bot_token
    end

    def send_message(chat_id, message, message_desc)
      options = { parse_mode: message_desc['telegram_parse_mode'] || 'HTML' }
      params = options.update(chat_id: chat_id, text: message)

      response = post_data(method_url('sendMessage'), params)
      [chat_id, response.code.to_i, response.body]
    end

    private

    def method_url(method)
      "https://api.telegram.org/bot#{@bot_token}/#{method}"
    end
  end
end
