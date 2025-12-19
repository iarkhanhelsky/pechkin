require 'bundler/setup'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:integration_spec) do |t|
  t.pattern = 'integration/**/*_spec.rb'
  t.rspec_opts = '--default-path integration'
end

RuboCop::RakeTask.new(:lint) do |t|
  t.options = %w[--display-style-guide --display-cop-names]
end

desc 'Run spec and linter'
task :default => %i[spec lint]
