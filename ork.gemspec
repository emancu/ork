Gem::Specification.new do |s|
  s.name        = 'ork'
  s.version     = '0.1.5'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Ruby modeling layer for Riak.'
  s.description = 'Ork is a small Ruby modeling layer for Riak, inspired by Ohm.'
  s.authors     = ['Emiliano Mancuso']
  s.email       = ['emiliano.mancuso@gmail.com']
  s.homepage    = 'http://github.com/emancu/ork'
  s.license     = 'MIT'

  s.files = Dir[
    'README.md',
    'rakefile',
    'lib/**/*.rb',
    '*.gemspec'
  ]
  s.test_files = Dir['test/*.*']

  s.add_runtime_dependency 'riak-client', '~> 1.4'
  s.add_development_dependency 'protest', '~> 0'
  s.add_development_dependency 'mocha', '~> 0'
end

