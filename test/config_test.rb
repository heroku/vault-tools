require 'helper'
require 'minitest/mock'

class ConfigTest < Vault::TestCase
  include Vault::Test::EnvironmentHelpers

  def teardown
    super
    Config.reset!
  end

  # Config.env returns the value matching the specified environment
  # variable name.
  def test_env
    set_env('VALUE', 'value')
    assert_equal(Config.env('VALUE'), 'value')
  end

  # Config[] returns the value matching the specified environment
  # variable name.
  def test_brackets
    set_env('VALUE', 'value')
    assert_equal(Config[:value], 'value')
  end

  # Config.env return nil if an unknown environment variable is
  # requested.
  def test_env_with_unknown_name
    assert_nil(Config.env('UNKNOWN'))
  end

  # Config.env! returns the value matching the specified environment
  # variable name.
  def test_env!
    set_env('VALUE', 'value')
    assert_equal(Config.env!('VALUE'), 'value')
  end

  # Config.env! raises a RuntimeError if an unknown environment
  # variable is requested.
  def test_env_with_unknown_name!
    error = assert_raises RuntimeError do
      Config.env!('UNKNOWN')
    end
    assert_equal(error.message, 'missing UNKNOWN')
  end

  # Config.production? is true when RACK_ENV=production.
  def test_production_mode
    set_env 'RACK_ENV', nil
    refute Config.production?
    set_env 'RACK_ENV', 'production'
    assert Config.production?
  end

  # Config.test? is true when RACK_ENV=test.
  def test_test_mode
    set_env 'RACK_ENV', nil
    refute Config.test?
    set_env 'RACK_ENV', 'test'
    assert Config.test?
  end

  # Returns DATABASE_URL with no params.
  def test_database_url
    set_env 'DATABASE_URL', "postgres:///foo"
    assert_equal(Config.database_url, 'postgres:///foo')
  end

  # Returns #{kind}_DATABASE_URL with one param
  def test_database_url_takes_and_capitalizes_params
    set_env 'FOO_DATABASE_URL', "postgres:///foo"
    assert_equal(Config.database_url('foo'), 'postgres:///foo')
  end

  # Config.database_url raises a RuntimeError if no DATABASE_URL
  # environment variables is defined.
  def test_database_url_raises_when_not_found
    assert_raises RuntimeError do
      Config.database_url('foo')
    end
  end

  # Config.app_name returns the value of the APP_NAME environment
  # variable.
  def test_app_name
    set_env 'APP_NAME', "my-app"
    assert_equal(Config.app_name, 'my-app')
  end

  # Config.app_deploy returns the value of the APP_DEPLOY environment
  # variable.
  def test_app_deploy
    set_env 'APP_DEPLOY', "test"
    assert_equal(Config.app_deploy, 'test')
  end

  # Config.port raises a RuntimeError if no `PORT` environment variable
  # is defined.
  def test_port_raises
    assert_raises RuntimeError do
      Config.port
    end
  end

  # Config.port converts the value from the environment to a Integer
  def test_port_convert_to_int
    set_env 'PORT', "3000"
    assert_equal(3000, Config.port)
  end

  # Config.enable_ssl? is true unless VAULT_TOOLS_DISABLE_SSL is set.
  def test_enable_ssl
    set_env 'VAULT_TOOLS_DISABLE_SSL', nil
    assert Config.enable_ssl?
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'true'
    refute Config.enable_ssl?
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'false'
    assert Config.enable_ssl?
  end

  # Config.int(VAR) returns nil or VAR as integer.
  def test_int
    assert_nil Config.int('FOO')
    set_env 'FOO', "3000"
    assert_equal(3000, Config.int('FOO'))
  end

  # Config.time returns nil or VAR as time
  def test_time
    assert_nil(Config.time('T'))
    set_env 'T', '2000'
    assert_equal(Time.utc(2000), Config.time(:t))
    set_env 'T', '2000-2'
    assert_equal(Time.utc(2000,2), Config.time(:t))
    set_env 'T', '2000-2-2'
    assert_equal(Time.utc(2000,2,2), Config.time(:t))
    set_env 'T', '2000-2-2T11:11'
    assert_equal(Time.utc(2000,2,2,11,11), Config.time(:t))
  end

  # Config.time returns nil or VAR as URI
  def test_uri
    assert_nil(Config.uri('URL'))
    set_env 'URL', 'http://user:password@the-web.com/path/to/greatness?foo=bar'
    uri = Config.uri('URL')
    assert_equal('http', uri.scheme)
    assert_equal('the-web.com', uri.host)
    assert_equal('/path/to/greatness', uri.path)
    assert_equal('foo=bar', uri.query)
    assert_equal(80, uri.port)
    assert_equal('user', uri.user)
    assert_equal('password', uri.password)
  end

  # Config.array loads a comma-separated list of words into an array of
  # strings.
  def test_array
    set_env 'ARRAY', ''
    assert_equal([], Config.array('ARRAY'))
    set_env 'ARRAY', 'apple'
    assert_equal(['apple'], Config.array('ARRAY'))
    set_env 'ARRAY', 'apple,orange,cherry'
    assert_equal(['apple', 'orange', 'cherry'], Config.array('ARRAY'))
  end

  # Config.bool?(var) is only true if the value of var is the string
  # 'true'.  If the var is absent or any other value, it evaluates to false.
  def test_bool_returns_true
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', 'true'
    assert_equal(true, Config.bool?('VAULT_BOOLEAN_VAR'))
  end

  # Config.bool?(var) is false if the value of var is anything other
  # than the string 'true'.
  def test_bool_returns_false
    set_env 'VAULT_BOOLEAN_VAR', 'false'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', 'foo'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', '1'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
  end

  # Config.sidekiq_concurrency returns the value of the
  # `SIDEKIQ_CONCURRENCY` environment variable or 25 if one isn't defined.
  def test_sidekiq_concurrency
    assert_equal(25, Config.sidekiq_concurrency)
    set_env 'SIDEKIQ_CONCURRENCY', '10'
    assert_equal(10, Config.sidekiq_concurrency)
  end

  # Confg.fetch(:some_var, 'whatever') will fallback to 'whatever' if SOME_VAR
  # is not defined.
  def test_fetch_allows_fallback_value
    assert_equal('bar', Config.fetch(:some_var, 'bar'))
    set_env 'SOME_VAR', 'foo'
    assert_equal('foo', Config.fetch(:some_var, 'bar'))
  end

  # Confg.fetch(:some_var, 'whatever') will allow SOME_VAR to be false
  def test_fetch_allows_value_to_be_false
    assert_equal('bar', Config.fetch(:some_var, 'bar'))
    set_env 'SOME_VAR', 'false'
    assert_equal('false', Config.fetch(:some_var, 'bar'))
  end
end
