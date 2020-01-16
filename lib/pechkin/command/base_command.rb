module Pechkin
  module Command
    # Basic class for all commands
    class BaseCommand
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def configuration
        config_dir = options.config_dir
        @configuration ||= Configuration.load_from_directory(config_dir)
      end

      def handler
        @handler ||= Handler.new(configuration.channels)
      end

      def matches?
        raise 'Unimplemented'
      end
    end
  end
end
