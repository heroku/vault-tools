require 'helper'

class TracingTest < Vault::TestCase
  def test_configure_not_enabled
    refute Vault::Tracing.configure
  end

  def test_enabled_true
    set_env('ZIPKIN_API_HOST', 'https://test-zipin.heroku.tools')
    set_env('ZIPKIN_ENABLED', 'true')
    assert Vault::Tracing.enabled?
  end

  def test_enabled_false
    refute Vault::Tracing.enabled?
  end
end
