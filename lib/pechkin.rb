require 'erb'
require 'rack'
require 'logger'

require_relative 'pechkin/cli'
require_relative 'pechkin/exceptions'
require_relative 'pechkin/handler'
require_relative 'pechkin/message_template'
require_relative 'pechkin/connector'
require_relative 'pechkin/connector_slack'
require_relative 'pechkin/connector_telegram'
require_relative 'pechkin/channel'
require_relative 'pechkin/http_handler'
require_relative 'pechkin/configuration'
require_relative 'pechkin/substitute'

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
        exit 0
      end

      run_server
    end

    def run_server
      http_handler = HttpHandler.new
      http_handler.handler = handler

      Rack::Server.start(app: HttpHandler.new(http_handler),
                         Port: options.port, pid:  options.pid_file)
    end

    def send_data
      ch, msg = options.send_data.match(%r{^([^/]+)/(.+)}) do |m|
        [m[1], m[2]]
      end

      raise "#{ch}/#{msg} not found" unless handler.message?(ch, msg)

      data = options.data
      if data.start_with?('@')
        f = data[1..-1]
        raise "File not found #{f}" unless File.exist?(f)

        data = IO.read(f)
      end

      handler.handle(ch, msg, JSON.parse(data, symbolize_names: true))
    end
  end
end
