require_relative 'command/base'

require_relative 'command/add_auth'
require_relative 'command/list'
require_relative 'command/check'
require_relative 'command/run_server'
require_relative 'command/send_data'

module Pechkin
  # Contains general command processing.
  module Command
    # Dispatch command. Commands are placed in fixed order to allow matching
    # rules be executed in right way. For example at first we check for
    # --add-auth and than for --check. At the moment only RunServer should be
    # last element of this sequence.
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
