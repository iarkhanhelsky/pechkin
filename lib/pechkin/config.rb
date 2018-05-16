require 'yaml'

module Pechkin
  class Config < OpenStruct
    def initialize(file)
      super(YAML.safe_load(IO.read(file)))
    end
  end
end
