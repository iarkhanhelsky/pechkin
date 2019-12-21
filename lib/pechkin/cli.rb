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

    def separator(string)
      @cli_options ||= []
      @cli_options << string
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
        new.post_init(values)
      end
    end

    def parser_create(values)
      parser = OptionParser.new
      parser.banner = @cli_banner

      (@cli_options || []).each do |o|
        if o.is_a?(String)
          parser.separator o
        else
          values[o[:name]] = o[:default] if o[:default]

          args = []
          args += o[:names]
          args << o[:type] if o[:type]
          args << o[:desc] if o[:desc]

          parser.on(*args) { |v| values[o[:name]] = v }
        end
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
    # Default file name for htpasswd file with auth credentials
    PECHKIN_HTPASSWD_FILE = 'pechkin.htpasswd'.freeze

    extend CLIHelper

    separator 'Run options'

    opt :config_file, default: Dir.pwd,
                      names: ['-c', '--config-dir FILE'],
                      desc: 'Path to configuration file'

    opt :port, names: ['--port PORT'], default: 9292, type: Integer

    opt :pid_file, names: ['-p', '--pid-file [FILE]'],
                   desc: 'Path to output PID file'

    opt :log_dir, names: ['--log-dir [DIR]'],
                  desc: 'Path to log directory. Output will be writen to'  \
                        'pechkin.log file. If not specified will write to' \
                        'STDOUT'
    opt :htpasswd, names: ['--auth-file FILE'],
                   desc: 'Path to .htpasswd file. By default ' \
                         '`pechkin.htpasswd` file will be looked up in ' \
                         'configuration directory and if found then ' \
                         'authorization will be enabled implicitly. ' \
                         'Providing this option enables htpasswd based ' \
                         'authorization explicitly. When making requests use ' \
                         'Basic auth to authorize.'

    separator 'Utils for configuration maintenance'
    opt :list?, names: ['-l', '--[no-]list'],
                desc: 'List all endpoints'

    opt :check?, names: ['-k', '--[no-]check'],
                 desc: 'Load configuration and exit'
    opt :send_data, names: ['-s', '--send ENDPOINT'],
                    desc: 'Send data to specified ENDPOINT and exit. ' \
                          'Requires --data to be set.'
    opt :preview,   names: ['--preview'],
                    desc: 'Print rendering result to STDOUT and exit. ' \
                          'Use with send'
    opt :data, names: ['--data DATA'],
               desc: 'Data to send with --send flag. Json string or @filename.'

    separator 'Auth utils'
    opt :add_auth, names: ['--add-auth USER:PASSWORD'],
                   desc: 'Add auth entry to .htpasswd file. By default ' \
                         'pechkin.htpasswd from configuration directory ' \
                         'will be used. Use --auth-file to specify other ' \
                         'file to update. If file does not exist it will be ' \
                         'created.'

    separator 'Debug options'
    opt :debug?, names: ['--[no-]debug'],
                 desc: 'Print debug information and stack trace on errors'

    def post_init(values)
      default_htpasswd = File.join(values.config_file, PECHKIN_HTPASSWD_FILE)
      if values.htpasswd.nil? && File.exist?(default_htpasswd)
        values.htpasswd = default_htpasswd
      end

      values
    end
  end
end
