require 'erb'
require 'rack'
require 'logger'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'powerpack/string'
require 'htauth'
require 'base64'

require_relative 'pechkin/cli'
require_relative 'pechkin/command'
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
      cmd = Command::Dispatcher.new(options).dispatch
      cmd.execute
    rescue StandardError => e
      warn 'Error: ' + e.message
      warn "\t" + e.backtrace.reverse.join("\n\t") if options.debug?
      exit 2
    end
  end
end
