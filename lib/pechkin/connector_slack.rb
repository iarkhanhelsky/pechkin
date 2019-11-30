module Pechkin # :nodoc:0
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
