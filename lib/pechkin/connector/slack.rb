module Pechkin
  module Connector
    class SlackApiRequestError < StandardError; end

    class Slack < Connector::Base # :nodoc:
      attr_reader :name

      def initialize(bot_token, name)
        super()

        @headers = { 'Authorization' => "Bearer #{bot_token}" }
        @name = name
      end

      def resolve_user_id(email, logger)
        url = 'https://slack.com/api/users.lookupByEmail?email=' + email

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.start_with?('https://')

        request = Net::HTTP::Get.new(uri.request_uri, @headers)

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          logger.warn email + "HTTPSuccess"
          resp = JSON.parse(response.body)
        else
          logger.warn email + "Sending failed" + response.message
          raise SlackApiRequestError, response.message
        end

        logger.warn email + " RESPONSE:" +resp["user"]["id"]

        resp["user"]["id"]
      end

      def send_message(channel, email, message, message_desc, logger)
        text = CGI.unescape_html(message)

        if (channel == "email")
          channel = resolve_user_id(email, logger)
        end

        attachments = message_desc['slack_attachments'] || {}

        if text.strip.empty? && attachments.empty?
          return { channel: channel, code: 400,
                   response: 'Internal error: message is empty' }
        end

        params = { channel: channel, text: text, attachments: attachments }

        url = 'https://slack.com/api/chat.postMessage'
        response = post_data(url, params, headers: @headers)

        logger.warn email + " RESPONSE: " + response.body

        { channel: channel, code: response.code.to_i, response: response.body }
      end
    end
  end
end
