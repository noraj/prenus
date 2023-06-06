# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
Gem::Specification.new do |s|
  s.name = "prenus"
  s.version = "0.0.12"
  s.authors = ["Christian Frichot"]
  s.date = "2013-10-08"
  s.description = "Pretty Nessus = Prenus"
  s.email = "xntrik@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = Dir["{lib}/**/*"] + %w[LICENSE.txt README.rdoc]
  s.executables = 'prenus'
  s.homepage = "http://github.com/AsteriskLabs/prenus"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = "Prenus - The Pretty Nessus Parser"

  s.required_ruby_version = '>= 3.0.0'

  s.add_runtime_dependency('rainbow', '~> 3.1', '>= 3.1.1')
  s.add_runtime_dependency('nokogiri', '~> 1.15', '>= 1.15.2')  
end