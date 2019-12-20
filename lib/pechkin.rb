require 'erb'
require 'rack'
require 'logger'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'htauth'
require 'base64'

require_relative 'pechkin/cli'
require_relative 'pechkin/exceptions'
require_relative 'pechkin/handler'
require_relative 'pechkin/message_template'
require_relative 'pechkin/connector'
require_relative 'pechkin/connector_slack'
require_relative 'pechkin/connector_telegram'
require_relative 'pechkin/channel'
require_relative 'pechkin/configuration'
require_relative 'pechkin/substitute'
require_relative 'pechkin/prometheus_utils'
require_relative 'pechkin/auth'
require_relative 'pechkin/app'

module Pechkin # :nodoc:
  class << self
    def run
      options = CLI.parse(ARGV)
      Main.new(options).run
    rescue StandardError => e
      warn 'Error: ' + e.message
      warn "\t" + e.backtrace.reverse.join("\n\t") if options.debug?
      exit 2
    end
  end

  class Main # :nodoc:
    attr_reader :options, :configuration, :handler

    def initialize(options)
      @options = options
      @configuration = Configuration.load_from_directory(options.config_file)
      @handler = Handler.new(@configuration.channels)
    end

    def run
      configuration.list if options.list?
      exit 0 if options.check?

      if options.send_data
        send_data
      elsif options.auth
        add_auth
      else
        run_server
      end
    end

    def run_server
      Rack::Server.start(app: AppBuilder.new.build(handler, options),
                         Port: options.port, pid:  options.pid_file)
    end

    def send_data
      ch, msg = parse_endpoint(options.send_data)

      raise "#{ch}/#{msg} not found" unless handler.message?(ch, msg)

      data = read_data(options.data)

      handler.preview = options.preview
      handler.handle(ch, msg, JSON.parse(data))
    end

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

    def add_auth
      user, password = options.auth.split(':')
      Pechkin::Auth::Manager.new(options.config_file).add(user, password)
    end
  end
end
