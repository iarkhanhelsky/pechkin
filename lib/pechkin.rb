require 'rack'
require 'logger'

require_relative 'pechkin/cli'
require_relative 'pechkin/api'
require_relative 'pechkin/config'

module Pechkin # :nodoc:
  class << self
    def run
      options = CLI.parse(ARGV)
      configuration = Config.new(options.config_file)
      log_dir = options.log_dir
      app = Pechkin.create(configuration)
      if log_dir
        app.logger = ::Logger.new(File.join(log_dir, 'pechkin.log'), 'daily')
      end
      Rack::Server.start(app: app,
                         Port: options.port || configuration.port,
                         pid: options.pid_file)
    end
  end
end
