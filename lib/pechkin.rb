require 'rack'

require_relative 'pechkin/cli'
require_relative 'pechkin/api'
require_relative 'pechkin/config'

module Pechkin # :nodoc:
  class << self
    def run
      options = CLI.parse(ARGV)
      configuration = Config.new(options.config_file)
      Rack::Server.start(app: Pechkin.create(configuration),
                         Port: options.port || configuration.port,
                         pid: options.pid_file)
    end
  end
end
