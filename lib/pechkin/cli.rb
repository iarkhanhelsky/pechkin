require 'optparse'
require 'optparse/time'
require 'ostruct'

require_relative 'version'

module Pechkin
  # Helper methods to declare all command line options. This should remove most
  # optparse configuration boilerplate
  module CLIHelper
    # @param name [Symbol] variable name to store values
    # @opt default [Object] default value
    # @opt names [Array<String>] list of command line keys
    # @opt desc [String] option description
    # @opt type [Class] argument type to parse from command line, e.g. Integer
    def opt(name, default: nil, names:, desc: '', type: nil)
      @cli_options ||= []

      # raise ':names is nil or empty' if names.nil? || names.empty?

      @cli_options << { name: name,
                        default: default,
                        names: names,
                        type: type,
                        desc: desc }
    end

    def banner(banner)
      @cli_banner = banner
    end

    def parse(args)
      values = OpenStruct.new
      parser = parser_create(values)

      if args.empty?
        puts parser.help
        exit 2
      else
        parser.parse(args)
        values
      end
    end

    def parser_create(values)
      parser = OptionParser.new
      parser.banner = @cli_banner

      (@cli_options || []).each do |o|
        values[o[:name]] = o[:default] if o[:default]

        args = []
        args += o[:names]
        args << o[:type] if o[:type]
        args << o[:desc] if o[:desc]

        parser.on(*args) { |v| values[o[:name]] = v }
      end

      parser_create_default_opts(parser)

      parser
    end

    def parser_create_default_opts(parser)
      parser.separator ''
      parser.separator 'Common options:'
      parser.on_tail('-h', '--help', 'Show this message') do
        puts parser
        exit 1
      end

      # Another typical switch to print the version.
      parser.on_tail('--version', 'Show version') do
        puts Version.version_string
        exit 0
      end
    end
  end

  # Command Line Parser Builder
  class CLI
    extend CLIHelper

    opt :config_file, default: Dir.pwd,
                      names: ['-c', '--config-dir FILE'],
                      desc: 'Path to configuration file'

    opt :port, names: ['--port PORT'], default: 9292, type: Integer

    opt :pid_file, names: ['-p', '--pid-file [FILE]'],
                   desc: 'Path to output PID file'

    opt :log_dir, names: ['--log-dir [DIR]'],
                  desc: 'Path to log directory'

    opt :list?, names: ['-l', '--[no-]list'],
                desc: 'List all endpoints'

    opt :check?, names: ['-k', '--[no-]check'],
                 desc: 'Load configuration and exit'

    opt :debug?, names: ['--[no-]debug'],
                 desc: 'Print debug information'

    opt :send_data, names: ['-s', '--send ENDPOINT'],
                    desc: 'Send data to specified ENDPOINT and exit. Requires' \
                          '--data to be set.'
    opt :data, names: ['--data DATA'],
               desc: 'Data to send with --send flag. Json string or @filename.'
  end
end
