require 'yaml'
require_relative '../lib/pechkin'

run Pechkin::create(YAML.load(IO.read('./config.yml')))
