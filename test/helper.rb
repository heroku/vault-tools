require 'vault-test-tools'
require 'vault-tools'
ENV['RACK_ENV'] = 'test'
Vault.setup

class Vault::TestCase
  include Vault::Test::EnvironmentHelpers
end
