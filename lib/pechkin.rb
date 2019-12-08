require 'rack'
require 'logger'

require_relative 'pechkin/cli'
require_relative 'pechkin/exceptions'
require_relative 'pechkin/handler'
require_relative 'pechkin/message'
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
      configuration = Configuration.new(options.config_file)

      if options.list
        configuration.list
      else
        setup_logging(options.log_dir) if options.log_dir
        handler = Handler.new(configuration.bots, configuration.channels)
        Rack::Server.start(app: HttpHandler.new(handler),
                           Port: options.port,
                           pid: options.pid_file)
      end
    end

    def setup_logging(_log_dir)
      # do nothing
    end
  end
end
