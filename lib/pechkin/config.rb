require 'yaml'

module Pechkin
  # Loads pechkin configuration
  class Config < OpenStruct
    def initialize(file)
      super(YAML.safe_load(IO.read(file)))
    end
  end
end
