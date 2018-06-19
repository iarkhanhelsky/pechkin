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

  s.add_runtime_dependency 'grape', '1.0.2'
  s.add_runtime_dependency 'rack', '1.3.0'
end
