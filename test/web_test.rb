require 'helper'

class WebTest < Vault::TestCase
  include Rack::Test::Methods
  include Vault::Test::EnvironmentHelpers
  include LoggedDataHelper

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
    Excon.defaults[:mock] = true
    set_env('APP_NAME', 'test-app')
    set_env('APP_DEPLOY', 'testing')
    reload_web!
  end

  def teardown
    super
    Excon.stubs.clear
    @app = nil
  end

  def test_http_basic_auth
    app.set :basic_password, 'password'
    app.get '/protected' do
      protected!
      'You may pass'
    end

    get '/protected'
    assert_equal 401, last_response.status
    authorize('','password')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body
  end

  def test_http_basic_auth_multi_pass
    app.set :basic_password, ['password', 'password2']
    app.get '/protected' do
      protected!
      'You may pass'
    end

    get '/protected'
    assert_equal 401, last_response.status

    authorize('','password')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body

    authorize('','password2')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body
  end

  def test_http_basic_auth_nil
    app.set :basic_password, nil
    app.get '/protected' do
      protected!
      'You may pass'
    end

    get '/protected'
    assert_equal 401, last_response.status
  end

  def test_http_basic_auth_with_alternate_password
    app.set :basic_password, 'password'
    app.get '/protected' do
      protected!('leelu-dallas-multipass')
      'You may pass'
    end

    get '/protected'
    assert_equal 401, last_response.status
    authorize('','password')
    get '/protected'
    assert_equal 401, last_response.status
    authorize('','leelu-dallas-multipass')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body
  end

  def test_http_basic_auth_with_two_passwords
    app.set :basic_password, 'password'
    app.get '/protected' do
      protected!('leelu-dallas-multipass','password')
      'You may pass'
    end

    get '/protected'
    assert_equal 401, last_response.status
    authorize('','password')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body
    authorize('','leelu-dallas-multipass')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body
  end

  def test_http_basic_auth_with_default_protected
    app.set :basic_password, 'password'
    app.before { protected! }
    app.get '/protected' do
      'You may pass'
    end
    app.get_unprotected '/unprotected/:name' do |name|
      "You may pass #{name}"
    end

    get '/protected'
    assert_equal 401, last_response.status

    head '/unprotected/Bob'
    assert_equal 200, last_response.status

    get '/unprotected/Bob'
    assert_equal 200, last_response.status
    assert_equal 'You may pass Bob', last_response.body

    authorize('','password')
    get '/protected'
    assert_equal 200, last_response.status
    assert_equal 'You may pass', last_response.body

    authorize('','password')
    get '/unprotected/Jill'
    assert_equal 200, last_response.status
    assert_equal 'You may pass Jill', last_response.body
  end

  # An `http_200` and an `http_2xx` log metric is written for successful
  # requests.
  def test_head_status_check
    head '/'
    assert_equal '1', logged_data['count#test-app.http.200']
    assert_equal '1', logged_data['count#test-app.http.2xx']
    assert_equal '/', logged_data['request_path']
    assert_equal(200, last_response.status)
  end

  # A GET /health request logs success metrics and returns 'OK' in the
  # response body.
  def test_get_health_check
    get '/health'
    assert_equal '1', logged_data['count#test-app.http.200']
    assert_equal '1', logged_data['count#test-app.http.2xx']
    assert_equal(200, last_response.status)
    assert_equal('OK', last_response.body)
  end

  # An `http_404` and an `http_4xx` log metric is written when a path doesn't
  # match a known resource.
  def test_head_with_unknown_endpoint
    head '/unknown'
    assert_equal '1', logged_data['count#test-app.http.404']
    assert_equal '1', logged_data['count#test-app.http.4xx']
    assert_equal(404, last_response.status)
  end

  # An `http_500` and an `http_5xx` log metric is written when an internal
  # server error occurs.  A traceback is written to the response body to ease
  # debugging.
  def test_error_logs_500
    get '/boom'
    assert_equal '1', logged_data['count#test-app.http.500']
    assert_equal '1', logged_data['count#test-app.http.5xx']
    assert_match(/^RuntimeError: An expected error occurred.$/m,
                 last_response.body)
    assert_equal(500, last_response.status)
  end

  # Test we register errors with Rollbar when they happen
  def test_error_with_rollbar
    assert_equal(0, Rollbar.exceptions.size)
    get '/boom'
    assert_equal(1, Rollbar.exceptions.size)
    error, _ = Rollbar.exceptions.first
    assert_equal(RuntimeError, error.class)
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

  # SSL is explicitly enforced when we're in production mode and the
  # `VAULT_TOOLS_DISABLE_SSL` environment variable is set to `false`.
  def test_ssl_explicitly_enforced_in_production_mode
    set_env 'RACK_ENV', 'production'
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'false'
    reload_web!
    get '/health'
    assert_equal(301, last_response.status)
    assert_match(/^https/, last_response.headers['Location'])
  end

  # SSL isn't enforced when the `VAULT_TOOLS_DISABLE_SSL` environment variable
  # is set to `true`.
  def test_ssl_can_be_disabled_in_production_mode
    set_env 'RACK_ENV', 'production'
    set_env 'VAULT_TOOLS_DISABLE_SSL', 'true'
    reload_web!
    get '/health'
    assert_equal(200, last_response.status)
  end

  def test_that_request_id_gets_logged
    request_id = 'JKJK-123'
    mock(Scrolls).log({
      'request-id' => request_id,
      'msg' => 'Hit logging test!',
      'source' => 'testing',
      'app' => 'test-app'
    })
    app.get '/logging-test' do
      Vault::Log.log('msg' => 'Hit logging test!')
    end

    header 'X_REQUEST_ID', request_id
    get '/logging-test'
    assert_equal request_id, last_response.headers['Request-ID']
  end

  def test_that_metadata_gets_logged
    mock(Vault::Log).count_status(200, {
      'user' => 'amanda',
      'some_flag' => 'true',
      request_path:  '/logging-test'
    })
    app.get '/logging-test' do
      @metadata = {'user' => 'amanda', 'some_flag' => 'true'}
    end
    get '/logging-test'
  end

  def test_that_excon_proxies_request_id
    request_id = 'JKJK-123'
    Excon.stub(
      { method: :get, host: 'example.com', path: '/',
        headers: {'X-Request-ID' => request_id}},
      { body: request_id, status: 200 })
    app.get '/proxy-test' do
      conn = Excon.new('http://example.com/')
      conn.get.body
    end

    header 'X_REQUEST_ID', request_id
    get '/proxy-test'
    assert_equal request_id, last_response.headers['Request-ID']
    assert_equal request_id, last_response.body
  end
end
