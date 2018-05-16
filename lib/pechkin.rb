require_relative 'pechkin/cli'
require_relative 'pechkin/api'

module Pechkin # :nodoc:
  class << self
    def run
      puts CLI.parse(ARGV)
    end
  end
end
