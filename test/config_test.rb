require 'helper'
require 'minitest/mock'

class ConfigTest < Vault::TestCase
  # Config.production? is true when RACK_ENV=production
  def test_production_mode
    set_env 'RACK_ENV', nil
    refute Vault::Config.production?
    set_env 'RACK_ENV', 'production'
    assert Vault::Config.production?
  end

  # Config.test? is true when RACK_ENV=test
  def test_test_mode
    set_env 'RACK_ENV', nil
    refute Vault::Config.test?
    set_env 'RACK_ENV', 'test'
    assert Vault::Config.test?
  end

  # Returns DATABASE_URL with no params
  def test_database_url
    set_env 'DATABASE_URL', "postgres:///foo"
    Vault::Config.database_url.must_equal 'postgres:///foo'
  end

  # Returns #{kind}_DATABASE_URL with one param
  def test_database_url_takes_and_capitalizes_params
    set_env 'FOO_DATABASE_URL', "postgres:///foo"
    Vault::Config.database_url('foo').must_equal 'postgres:///foo'
  end

  def test_database_url_raises_when_not_found
    assert_raises RuntimeError do
      Vault::Config.database_url('foo')
    end
  end

  # Vault::Config.app_name returns the value of the APP_NAME environment
  # variable.
  def test_app_name
    Vault::Config.app_name.must_equal nil
    set_env 'APP_NAME', "my-app"
    Vault::Config.app_name.must_equal 'my-app'
  end

  def test_port_raises
    assert_raises RuntimeError do
      Vault::Config.port
    end
  end

  def test_port_convert_to_int
    set_env 'PORT', "3000"
    Vault::Config.port.must_equal 3000
  end

  # Config.int(VAR) returns nil or VAR as integer
  def test_int
    assert_equal(nil, Vault::Config.int('FOO'))
    set_env 'FOO', "3000"
    assert_equal(3000, Vault::Config.int('FOO'))
  end

  # Config.enable_ssl? is true unless VAULT_TOOLS_DISABLE_SSL
  # is set
  def test_enable_ssl
    set_env 'VAULT_TOOLS_DISABLE_SSL', nil
    assert Vault::Config.enable_ssl?
    set_env 'VAULT_TOOLS_DISABLE_SSL', '1'
    refute Vault::Config.enable_ssl?
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'foo'
    refute Vault::Config.enable_ssl?
  end

  # Config.remote_env uses Heroku API to read config
  # vars from apps
  def test_remote_env
    api_mock = MiniTest::Mock.new
    api_response = OpenStruct.new(body: {'DATABASE_URL' => 'postgres:///foo'})
    Heroku::API.stub(:new, api_mock) do
      api_mock.expect(:get_config_vars, api_response, ['app'])
      assert_equal('postgres:///foo', Vault::Config.remote_env('app', 'DATABASE_URL'))
    end
  end
end
