require_relative 'pechkin/cli'

module Pechkin # :nodoc:
  class << self
    def run
      puts CLI::parse(ARGV)
    end
  end
end
