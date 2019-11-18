require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'cgi'

module Pechkin
  # Base connector
  class Connector
    def send_message(chat, message, message_desc); end

    def post_data(url, data, headers: {})
      uri = URI.parse(url)
      headers = { 'Content-Type' => 'application/json' }.merge(headers)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = url.start_with?('https://')

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = data.to_json

      http.request(request)
    end
  end

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

  class SlackConnector < Connector # :nodoc:
    def initialize(bot_token)
      @headers = { 'Authorization' => "Bearer #{bot_token}" }
    end

    def send_message(chat, message, message_desc)
      text = CGI.unescape_html(message)

      attachments = message_desc['slack_attachments'] || {}

      if text.strip.empty? && attachments.empty?
        return [chat, 400, 'not sent: empty']
      end

      params = { channel: chat, text: text, attachments: attachments }

      url = 'https://slack.com/api/chat.postMessage'
      response = post_data(url, params, headers: @headers)

      [chat, response.code.to_i, response.body]
    end
  end
end
