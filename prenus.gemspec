# frozen_string_literal: true

# require_relative 'lib/prenus'

Gem::Specification.new do |s|
  s.name = 'prenus'
  s.version = '0.0.13'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Christian Frichot', 'Alexandre ZANNI']
  s.date = '2013-10-08'
  s.description = 'Pretty Nessus = Prenus'
  s.summary = 'Prenus - The Pretty Nessus Parser'
  s.email = 'xntrik@gmail.com'
  s.licenses = ['MIT']
  s.homepage = 'http://github.com/noraj/prenus'

  s.files = Dir['bin/*'] + Dir['lib/**/*'] + %w[LICENSE.txt README.md]
  s.bindir = 'bin'
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.0.0'

  s.add_runtime_dependency('nokogiri', '~> 1.15', '>= 1.15.2')
  s.add_runtime_dependency('rainbow', '~> 3.1', '>= 3.1.1')
end
