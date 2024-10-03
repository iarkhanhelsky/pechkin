module Pechkin
  module Connector
    # Base connector
    class Base
      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json; charset=UTF-8'
      }.freeze

      def send_message(chat, message, message_desc); end

      def expand_chat_ids(chat_ids, _data)
        chat_ids
      end

      def preview(chats, message, _message_desc)
        "Connector: #{self.class.name}; Chats: #{chats.join(', ')}\n" \
        "Message:\n#{message}"
      end

      def post_data(url, data, headers: {})
        uri = URI.parse(url)
        headers = DEFAULT_HEADERS.merge(headers)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.start_with?('https://')

        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = data.to_json

        http.request(request)
      end
    end
  end
end
