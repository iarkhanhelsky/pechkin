require 'optparse'
require 'optparse/time'
require 'ostruct'

require_relative 'version'

module Pechkin
  # Command Line parser
  module CLI
    # Command Line Parser Builder
    class CLIBuilder
      attr_reader :options
      def initialize(options_keeper)
        @options = options_keeper
      end

      def build(parser) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        # rubocop:disable Metrics/LineLength
        parser.banner = 'Usage: pechkin [options]'
        parser.separator ''

        parser.on('-c', '--config CONFIG_FILE', 'default value is /etc/pechkin/config.yml') do |value|
          options.config_file = value
        end

        parser.on('-p', '--port PORT', Integer) do |value|
          options.port = value.to
        end

        parser.on('--log-dir') do |value|
          options.log_dir = value
        end

        parser.separator ''
        parser.separator 'Common options:'
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail('--version', 'Show version') do
          puts Version.version_string
          exit
        end
        # rubocop:enable Metrics/LineLength
      end
    end

    class << self
      def parse(_args)
        options_keeper = OpenStruct.new
        parser = OptionParser.new do |p|
          CLIBuilder.new(options_keeper).build(p)
        end

        parser.parse(args)
        options_keeper
      end
    end
  end
end
