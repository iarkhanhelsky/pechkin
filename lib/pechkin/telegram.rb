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
      def initialize(bot_token, chat_ids)
        @bot_token = bot_token
        @chat_ids = chat_ids
        @chat_ids = [chat_ids] unless chat_ids.is_a?(Array)
      end

      def send_message(message, data, options)
        text = Message.new(data).render(message)
        @chat_ids.map do |chat|
          params = options.update(text: text, chat_id: chat)
          response = send_data('sendMessage', params)
          [response.code, response.body]
        end
      end

      def send_data(method, data = {})
        url = URI.parse(method_url(method))
        Net::HTTP.post_form(url, data)
      end

      def method_url(method)
        "https://api.telegram.org/bot#{@bot_token}/#{method}"
      end
    end
  end
end
