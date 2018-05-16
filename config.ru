require 'yaml'
require_relative './lib/pechkin'

run Pechkin::App.configure(YAML.load(IO.read('./config.yml')))
