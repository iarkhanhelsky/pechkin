module Pechkin
  module Connector
    class Slack < Connector::Base # :nodoc:
      attr_reader :name

      def initialize(bot_token, name)
        super()

        @headers = { 'Authorization' => "Bearer #{bot_token}",
                     'Content-Type' => 'application/json; charset=UTF-8' }
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

      def expand_chat_ids(chat_ids, data); end

      private

      def resolve(chat_id, data)
        if chat_id.is_a?(Hash)
          type = chat_id['type']
          value = resolve(chat_id['value'], data)

          case type
          when 'email'
            lookup_by_email(value)
          when 'channel'
            value
          else
            raise "unsupported type: #{type}"
          end
        elsif chat_id.start_with?('.')
          _, *rest = value.split('.')
          rest.inject(data) { |d, k| d[k] }
        else
          chat_id
        end
      end

      def lookup_by_email(email)
        url = "https://slack.com/api/users.lookupByEmail?email=#{email}"

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.start_with?('https://')

        request = Net::HTTP::Get.new(uri.request_uri, @headers)
        resp = JSON.parse(http.request(request).body)

        resp['user']['id']
      end
    end
  end
end
