require 'helper'

class WebTest < Vault::TestCase
  include Rack::Test::Methods

  # Anonymous Web Frontend
  def app
    Class.new(Vault::Web)
  end

  # Always reload the web class to eliminate test leakage
  def setup
    super
    reload_web!
  end

  # middleware is attached at load time, so we have to
  # delete the web class and reload it to simulate being
  # loaded with a given ENV
  def reload_web!
    # remove the constant to force a clean reload
    Vault.send(:remove_const, 'Web')
    load 'lib/vault-tools/web.rb'
  end

  # A successful request causes a `web-20` log entry to be written.
  def test_head_status_check
    head '/'
    assert_match(/measure=true/, Scrolls.stream.string)
    assert_match(/at=web-20/, Scrolls.stream.string)
    assert_equal(200, last_response.status)
  end

  # A successful request causes `web-20` log entry to be written and `OK`
  # content is returned in the response body.
  def test_get_health_check
    get '/health'
    assert_match(/measure=true/, Scrolls.stream.string)
    assert_match(/at=web-20/, Scrolls.stream.string)
    assert_equal(200, last_response.status)
    assert_equal('OK', last_response.body)
  end

  # A validation error causes a `web-40` log entry to be written.
  def test_head_with_unknown_endpoint
    head '/unknown'
    assert_match(/measure=true/, Scrolls.stream.string)
    assert_match(/at=web-40/, Scrolls.stream.string)
    assert_equal(404, last_response.status)
  end

  # An internal server error causes a `web-50` log entry to be written.  A
  # traceback is also written to the response body to ease debugging.
  def test_error_logs_500
    get '/boom'
    assert_match(/measure=true/, Scrolls.stream.string)
    assert_match(/at=web-50/, Scrolls.stream.string)
    assert_match(/^RuntimeError: An expected error occurred.$/m,
                 last_response.body)
    assert_equal(500, last_response.status)
  end


  # SSL is enforced when we are in production mode
  def test_ssl_enforced_in_production_mode
    set_env 'RACK_ENV', 'production'
    reload_web!
    get '/health'
    assert_equal(301, last_response.status)
    assert_match(/^https/, last_response.headers['Location'])
  end

  def test_ssl_can_be_disabled
    set_env 'RACK_ENV', 'production'
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'anything'
    reload_web!
    get '/health'
    assert_equal(200, last_response.status)
  end
end
