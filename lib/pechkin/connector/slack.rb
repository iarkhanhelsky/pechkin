module Pechkin
  module Connector
    class Slack < Connector::Base # :nodoc:
      attr_reader :name

      def initialize(bot_token, name)
        @headers = { 'Authorization' => "Bearer #{bot_token}" }
        @name = name
      end

      def send_message(channel, message, message_desc)
        text = CGI.unescape_html(message)

        attachments = message_desc['slack_attachments'] || {}

        if text.strip.empty? && attachments.empty?
          return { channel: channel, code: 400,
                   response: 'Internal error: message is empty' }
        end

        params = { channel: channel, text: text, attachments: attachments }

        url = 'https://slack.com/api/chat.postMessage'
        response = post_data(url, params, headers: @headers)

        { channel: channel, code: response.code.to_i, response: response.body }
      end
    end
  end
end
