module Pechkin
  # Keeps actual version
  module Version
    VERSION = [1, 3, 2].freeze
    class << self
      def version_string
        VERSION.join('.')
      end
    end
  end
end
