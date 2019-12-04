require 'rack'
require 'logger'

require_relative 'pechkin/cli'
require_relative 'pechkin/exceptions'
require_relative 'pechkin/handler'
require_relative 'pechkin/message'
require_relative 'pechkin/connector'
require_relative 'pechkin/connector_slack'
require_relative 'pechkin/connector_telegram'
require_relative 'pechkin/channel'
require_relative 'pechkin/api'
require_relative 'pechkin/config'
require_relative 'pechkin/substitute'

module Pechkin # :nodoc:
  class << self
    def run
      options = CLI.parse(ARGV)
      configuration = Config.new(options.config_file)
      setup_logging(options.log_dir) if options.log_dir
      app = Pechkin.create(configuration)
      PechkinAPI.logger.info 'Starting pechkin service...'
      Rack::Server.start(app: app,
                         Port: options.port || configuration.port,
                         pid: options.pid_file)
    end

    def setup_logging(log_dir)
      logger = ::Logger.new(File.join(log_dir, 'pechkin.log'), 'daily')
      logger.level = ::Logger::INFO

      PechkinAPI.logger = logger
    end
  end
end
