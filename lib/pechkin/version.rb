module Pechkin
  # Keeps actual version
  module Version
    VERSION = [0, 0, 1].freeze
    class << self
      def version_string
        ['pechkin', VERSION.join('.')].join(' ')
      end
    end
  end
end
