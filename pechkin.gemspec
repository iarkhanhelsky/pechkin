require_relative './lib/pechkin/version'

Gem::Specification.new do |s|
  s.name        = 'pechkin'
  s.version     = Pechkin::Version.version_string
  s.licenses    = ['MIT']
  s.summary     = 'Web service to proxy webhooks to Telegram Bot API'
  s.authors     = ['Ilya Arkhanhelsky']
  s.email       = 'ilya.arkhanhelsky at gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables << 'pechkin'
  s.homepage = 'https://github.com/iarkhanhelsky/pechkin'

  s.required_ruby_version = '>= 3.0'

  s.add_runtime_dependency 'htauth', '2.2.0'
  s.add_runtime_dependency 'powerpack', '0.1.3'
  s.add_runtime_dependency 'prometheus-client', '4.2.2'
  s.add_runtime_dependency 'puma', '6.4.2'
  s.add_runtime_dependency 'rack', '3.0.8'
end
