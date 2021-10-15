module Pechkin
  module Command
    # Basic class for all commands
    class Base
      attr_reader :options

      # Initializes command state
      # @param options [OpenStruct] set of options which allows to configure
      #   command behaviour
      # @opt stdout [IO] IO object which represents STDOUT
      # @opt stderr [IO] IO object which represents STDERR
      def initialize(options, stdout: $stdout, stderr: $stderr)
        @options = options
        @stdout = stdout
        @stderr = stderr
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

      def puts(*args)
        @stdout.puts(*args)
      end

      def warn(*args)
        @stderr.puts(*args)
      end
    end
  end
end
