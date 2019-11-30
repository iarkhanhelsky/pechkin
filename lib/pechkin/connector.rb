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
end
