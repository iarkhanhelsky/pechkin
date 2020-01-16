module Pechkin
  module Command
    # List channels configuration
    class List < BaseCommand
      def matches?
        options.list?
      end

      def execute
        configuration.list
      end
    end
  end
end
