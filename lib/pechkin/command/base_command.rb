module Pechkin
  module Command
    # Basic class for all commands
    class BaseCommand
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def configuration
        @configuration ||= Configuration.load_from_directory(options.config_file)
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
