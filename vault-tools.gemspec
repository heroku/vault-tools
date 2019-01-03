# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vault-tools/version'

Gem::Specification.new do |gem|
  gem.name          = "vault-tools"
  gem.version       = Vault::Tools::VERSION
  gem.authors       = ["Chris Continanza", "Jamu Kakar"]
  gem.email         = ["christopher.continanza@gmail.com", "csquared@heroku.com","jkakar@heroku.com","jkakar@kakar.ca"]
  gem.description   = "Basic tools for Heroku Vault's Ruby projects"
  gem.summary       = "Test classes, base web classes, and helpers - oh my!"
  gem.homepage      = ""
  gem.required_ruby_version = '>= 2.5.3'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep('^(test|spec|features)/')
  gem.require_paths = ["lib"]

  gem.add_dependency 'scrolls', '~> 0.9'
  gem.add_dependency 'sinatra', '~> 2.0.4'
  gem.add_dependency 'uuidtools'
  gem.add_dependency 'rack-ssl-enforcer'
  gem.add_dependency 'fernet', '2.0.rc2'
  gem.add_dependency 'rollbar', '~> 2.18.2'
  gem.add_dependency 'aws-sdk', '~> 3.0'
  gem.add_dependency 'excon'
  gem.add_dependency 'rack', '~> 2.0'
  gem.add_dependency 'coderay'

  gem.add_development_dependency 'dotenv'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'yard'
end
