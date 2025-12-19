require 'rspec'
require 'ostruct'
require 'timeout'
require 'webmock/rspec'

# Configure WebMock to intercept external API calls
WebMock.disable_net_connect!

# Load Pechkin library
require_relative '../lib/pechkin'
require_relative 'support/integration_helper'

RSpec.configure do |config|
  config.include Pechkin::Integration::IntegrationHelper

  # Use expect syntax
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  # Disable monkey patching
  config.disable_monkey_patching!

  # Use color output
  config.color = true

  # Show detailed failure output
  config.formatter = :progress
end

# Custom matchers for integration tests
