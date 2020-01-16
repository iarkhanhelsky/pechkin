module Pechkin
  module Command
    # Send data to channel and exit. Uses --preview flag to render message and
    # flush it to STDOUT before sending
    class SendData < BaseCommand
      def matches?
        options.send_data
      end

      def execute
        ch, msg = parse_endpoint(options.send_data)

        raise "#{ch}/#{msg} not found" unless handler.message?(ch, msg)

        data = read_data(options.data)

        handler.preview = options.preview
        handler.handle(ch, msg, JSON.parse(data))
      end

      private

      def read_data(data)
        return data unless data.start_with?('@')

        file = data[1..-1]
        raise "File not found #{file}" unless File.exist?(file)

        IO.read(file)
      end

      def parse_endpoint(endpoint)
        endpoint.match(%r{^([^/]+)/(.+)}) do |m|
          [m[1], m[2]]
        end
      end
    end
  end
end
