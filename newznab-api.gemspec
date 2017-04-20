# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newznab/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'newznab-api'
  spec.version       = Newznab::Api::VERSION
  spec.authors       = ['Holden Omans']
  spec.email         = ['holden.omans@gmail.com']

  spec.summary       = %q{Api interface to Newznab servers.}
  spec.description   = %q{Api interface to Newznab servers. Allows for searches and returning specific information on resources.}
  spec.homepage      = 'https://github.com/kalinon/ruby-newznab-api'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2'

  spec.cert_chain  = ['certs/homans.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $0 =~ /gem\z/

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.9', '>= 5.9.1'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1', '>= 1.1.12'
  spec.add_development_dependency 'rdoc', '~> 4.2', '>= 4.2.1'
  spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.5'
  spec.add_development_dependency 'dotenv-rails'
  spec.add_development_dependency 'faker'

  # Dependencies
  spec.add_dependency 'rest-client', '~> 2.0'
end
