require 'helper'

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

  def test_service_name_gets_herokuapp
    assert_equal 'test_app.herokuapp.com', Vault::Tracing.config[:service_name]
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
