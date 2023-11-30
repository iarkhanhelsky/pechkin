module Pechkin
  # Keeps actual version
  module Version
    VERSION = [2, 0, 1].freeze
    class << self
      def version_string
        VERSION.join('.')
      end
    end
  end
end
