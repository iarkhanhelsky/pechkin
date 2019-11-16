module Pechkin # :nodoc:
  # Replaces ${:varname:} patterns inside strings. All posible substitutions are
  # provided through constructor.
  #
  # Complex templating and text fromatting (like float numbers formatting) is
  # not a goal. We do not aim to implement new templating engine here. Just
  # simple stuff.
  class Substitute
    # @param substitutions [Hash] hash of possible substitutions for replacement
    def initialize(substitutions)
      @substitutions = substitutions
    end

    def process(string)
      string.gsub(/\$\{([A-Za-z0-9_]+)\}/) do |m|
        key = m[2..-2]

        value = @substitutions[key] || @substitutions[key.to_sym]

        (value || m).to_s
      end
    end
  end
end
