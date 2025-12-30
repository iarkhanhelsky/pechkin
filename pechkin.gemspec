require_relative './lib/pechkin/version'

Gem::Specification.new do |s|
  s.name        = 'pechkin'
  s.version     = Pechkin::Version.version_string
  s.licenses    = ['MIT']
  s.summary     = 'Template-driven webhook-to-Slack/Telegram proxy'
  s.description = 'Pechkin runs an HTTP server that accepts JSON webhooks and turns them into formatted Slack or Telegram messages. Configure bots, channels, filters, and templates to route and render requests. Optional Basic Auth (.htpasswd) and Prometheus metrics are included.'
  s.authors     = ['Ilya Arkhanhelsky']
  s.email       = 'ilya.arkhanhelsky at gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables << 'pechkin'
  s.homepage = 'https://github.com/iarkhanhelsky/pechkin'

  s.required_ruby_version = '>= 3.0'

  s.add_runtime_dependency 'htauth', '~> 2.2.0'
  s.add_runtime_dependency 'powerpack', '~> 0.1.3'
  s.add_runtime_dependency 'prometheus-client', '~> 4.2.5'
  s.add_runtime_dependency 'puma', '~> 7.1.0'
  s.add_runtime_dependency 'rack', '~> 3.2.0'
end
