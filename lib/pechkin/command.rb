require_relative 'command/base_command'

require_relative 'command/add_auth'
require_relative 'command/list'
require_relative 'command/check'
require_relative 'command/run_server'
require_relative 'command/send_data'

module Pechkin
  # Contains general command processing.
  module Command
    # Dispatch command
    class Dispatcher
      COMMANDS = [
        AddAuth,
        Check,
        List,
        SendData,
        RunServer
      ].freeze

      attr_reader :options

      # @param cli_options [OpenStruct] command line options object
      def initialize(cli_options)
        @options = cli_options
      end

      # Dispatch command according to provided options
      def dispatch
        COMMANDS.map { |c| c.new(options) }.find(&:matches?).execute
      end
    end
  end
end
