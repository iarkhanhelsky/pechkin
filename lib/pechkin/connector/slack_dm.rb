module Pechkin
  module Connector
    class SlackDM < Connector::Base # :nodoc:
      attr_reader :name

      def initialize(bot_token, name)
        super()

        @headers = { 'Authorization' => "Bearer #{bot_token}", 'Content-Type' => 'application/json; charset=UTF-8' }
        @name = name
      end

      def resolve_user_id(email)
        url = 'https://slack.com/api/users.lookupByEmail?email=' + email

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.start_with?('https://')

        request = Net::HTTP::Get.new(uri.request_uri, @headers)

        resp = JSON.parse(http.request(request).body)

        resp["user"]["id"]
      end

      def send_message(passed_email, message, message_desc)
        channel = resolve_user_id(passed_email)

        text = CGI.unescape_html(message)

        attachments = message_desc['slack_attachments'] || {}

        if text.strip.empty? && attachments.empty?
          return { channel: channel, code: 400,
                   response: 'Internal error: message is empty' }
        end

        params = { channel: channel, attachments: attachments }

        url = 'https://slack.com/api/chat.postMessage'
        response = post_data(url, params, headers: @headers)

        { channel: channel, code: response.code.to_i, response: response.body }
      end
    end
  end
end
