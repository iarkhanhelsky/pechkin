module Pechkin
  module Command
    # List channels configuration
    class List < Base
      def matches?
        options.list?
      end

      def execute
        configuration.list
      end
    end
  end
end
