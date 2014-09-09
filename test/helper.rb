require 'vault-test-tools'
require 'vault-tools'
require 'rr'

ENV['RACK_ENV'] = 'test'

module LoggedDataHelper
  def logged_data
    Hash[Scrolls.stream.string.split(/\s+/).map {|p| p.split('=') }]
  end
end

# Overwrite the Honeybadger module
module Honeybadger
  # A place to store the exceptions
  def self.exceptions
    @exceptions ||= []
  end

  # Store calls to notify in an array instead
  # of calling out to the Honeybadger service
  def self.notify(exception, opts = {})
    self.exceptions << [exception, opts]
  end
end

# Clear the stored exceptions in Honeybadger
# so each test starts w. a clean slate
module HoneybadgerHelper
  def setup
    super
    Honeybadger.exceptions.clear
  end
end

class Vault::TestCase
  include Vault::Test::EnvironmentHelpers
  include HoneybadgerHelper
end

Vault.setup
