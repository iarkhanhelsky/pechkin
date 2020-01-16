module Pechkin
  module Command
    # Check configuration consistency and exit.
    class Check < BaseCommand
      def matches?
        options.check?
      end

      def execute
        configuration # load configuration from disk and do nothing more
      end
    end
  end
end
