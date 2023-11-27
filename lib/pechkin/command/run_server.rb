module Pechkin
  module Command
    # Start pechkin HTTP server
    class RunServer < Base
      def matches?
        true # Always match
      end

      def execute
        app = AppBuilder.new.build(handler, options)

        server = Puma::Server.new(app).tap do |s|
          s.add_tcp_listener(options.host, options.port)
        end

        server.run(false)
      end
    end
  end
end
