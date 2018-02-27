require 'helper'
require 'sidekiq'

class TracingTest < Vault::TestCase
  # Anonymous Web Frontend
  def app
    @app ||= Class.new(Vault::Web)
  end

  # Middleware is attached at load time, so we have to delete the Vault::Web
  # class and reload it to simulate being loaded with different environment
  # variables.
  def reload_web!
    # remove the constant to force a clean reload
    Vault.send(:remove_const, 'Web')
    load 'lib/vault-tools/web.rb'
  end

  # Always reload the web class to eliminate test leakage
  def setup
    super
    reload_web!
    enable
  end

  def teardown
    super
    @app = nil
  end

  def enable
    set_env('APP_NAME', 'test_app')
    set_env('ZIPKIN_ENABLED', 'true')
    set_env('ZIPKIN_API_HOST', 'http://localhost')
  end

  def disable
    set_env('ZIPKIN_ENABLED', nil)
  end

  def test_configure_enabled
    Vault::Tracing.configure
    middleware_constants = app.middleware.map(&:first)
    assert middleware_constants.include?(ZipkinTracer::RackHandler),
      "expected ZipkinTracer::RackHandler to be in the middleware stack, got #{middleware_constants}"
  end

  def test_configure_not_enabled
    disable
    refute Vault::Tracing.configure,
      'Vault::Tracing.configure should return nil when not enabled'
  end

  def test_excon
    enable
    Vault::Tracing.configure
    assert Excon.defaults[:middlewares].include?(ZipkinTracer::ExconHandler),
      "Vault::Tracing.setup_excon should add ZipkinTracer::ExconHandler to excon's middleware"
  end

  def test_sidekiq
    enable
    sidekiq_mock = Minitest::Mock.new
    sidekiq_mock.expect :configure_server, true
    sidekiq_mock.expect :configure_client, true
    Vault::Tracing.setup_sidekiq(sidekiq_mock)
    assert sidekiq_mock.verify,
      "Vault::Tracing.setup_sidekiq should call ::configure_server, and ::configure_client on Sidekiq"
  end

  def test_enabled_true
    assert Vault::Tracing.enabled?,
      'Vault::Tracing.enabled? should return true when enabled'
  end

  def test_enabled_false
    disable
    refute Vault::Tracing.enabled?,
      'Vault::Tracing.enabled? should return false when not enabled'
  end
end
