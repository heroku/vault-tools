require 'helper'

class WebTest < Vault::TestCase
  include Rack::Test::Methods

  # Anonymous Web Frontend
  def app
    @app ||= Class.new(Vault::Web)
  end

  # Always reload the web class to eliminate test leakage
  def setup
    super
    reload_web!
  end

  def test_http_basic_auth
    app.set :basic_password, 'password'
    app.get '/protected' do
      protected!
      'OKIE'
    end

    get '/protected'
    assert_equal 401, last_response.status
    authorize('','password')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'OKIE', last_response.body
  end

  # Middleware is attached at load time, so we have to delete the Vault::Web
  # class and reload it to simulate being loaded with different environment
  # variables.
  def reload_web!
    # remove the constant to force a clean reload
    Vault.send(:remove_const, 'Web')
    load 'lib/vault-tools/web.rb'
  end

  # An `http_200` and an `http_2xx` log metric is written for successful
  # requests.
  def test_head_status_check
    head '/'
    assert_match(/count#http_200=1/, Scrolls.stream.string)
    assert_match(/count#http_2xx=1/, Scrolls.stream.string)
    assert_equal(200, last_response.status)
  end

  # A GET /health request logs success metrics and returns 'OK' in the
  # response body.
  def test_get_health_check
    get '/health'
    assert_match(/count#http_200=1/, Scrolls.stream.string)
    assert_match(/count#http_2xx=1/, Scrolls.stream.string)
    assert_equal(200, last_response.status)
    assert_equal('OK', last_response.body)
  end

  # An `http_404` and an `http_4xx` log metric is written when a path doesn't
  # match a known resource.
  def test_head_with_unknown_endpoint
    head '/unknown'
    assert_match(/count#http_404=1/, Scrolls.stream.string)
    assert_match(/count#http_4xx=1/, Scrolls.stream.string)
    assert_equal(404, last_response.status)
  end

  # An internal server error causes a `web-50` log entry to be written.  A
  # traceback is also written to the response body to ease debugging.
  def test_error_logs_500
    get '/boom'
    assert_match(/count#http_500=1/, Scrolls.stream.string)
    assert_match(/count#http_5xx=1/, Scrolls.stream.string)
    assert_match(/^RuntimeError: An expected error occurred.$/m,
                 last_response.body)
    assert_equal(500, last_response.status)
  end

  # SSL is enforced when we are in production mode
  def test_ssl_enforced_in_production_mode
    set_env 'RACK_ENV', 'production'
    set_env 'VAULT_TOOLS_DISABLE_SSL', nil
    reload_web!
    get '/health'
    assert_equal(301, last_response.status)
    assert_match(/^https/, last_response.headers['Location'])
  end

  # SSL isn't enforced when the VAULT_TOOLS_DISABLE_SSL environment variable
  # has a true value.
  def test_ssl_can_be_disabled
    set_env 'RACK_ENV', 'production'
    set_env 'VAULT_TOOLS_DISABLE_SSL', '1'
    reload_web!
    get '/health'
    assert_equal(200, last_response.status)
  end
end
