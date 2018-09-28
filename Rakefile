require 'bundler/setup'
require 'grably'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:lint) do |t|
  t.options = %w[--display-style-guide --display-cop-names]
end

desc 'Run spec and linter'
task :default => %i[spec lint]
