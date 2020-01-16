module Pechkin
  module Command
    # Start pechkin HTTP server
    class RunServer < BaseCommand
      def matches?
        true # Always match
      end

      def execute
        Rack::Server.start(app: AppBuilder.new.build(handler, options),
                           Port: options.port, pid: options.pid_file)
      end
    end
  end
end
