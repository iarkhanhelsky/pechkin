module Pechkin
  # Keeps actual version
  module Version
    VERSION = [0, 1, 3].freeze
    class << self
      def version_string
        VERSION.join('.')
      end
    end
  end
end
