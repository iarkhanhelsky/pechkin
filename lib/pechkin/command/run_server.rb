require 'puma/configuration'

module Pechkin
  module Command
    # Start pechkin HTTP server
    class RunServer < Base
      def matches?
        true # Always match
      end

      def execute
        # Configure Puma server instead config.ru
        puma_config = Puma::Configuration.new do |user_config|
          user_config.bind "tcp://#{options.bind_address}:#{options.port}"
          user_config.workers options.server_workers  # Set number of workers
          user_config.threads options.min_threads, options.max_threads # Set max and min threads
          user_config.app AppBuilder.new.build(handler, options)
        end

        # Run Puma server with configuration
        launcher = Puma::Launcher.new(puma_config)
        launcher.run
      end
    end
  end
end
