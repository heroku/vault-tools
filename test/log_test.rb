require 'helper'

class LogTest < Vault::TestCase
  include LoggedDataHelper

  def setup
    super
    set_env('APP_NAME', 'test-app')
    set_env('APP_DEPLOY', 'test-deploy')
  end

  # Vault::Log.count emits a metric, using the specified name, that represents
  # a countable event.
  def test_count
    Vault::Log.count('countable')
    assert_equal '1', logged_data['count#test-app.countable']
    assert_equal 'test-deploy', logged_data['source']
  end

  def test_count_with_specified_value
    Vault::Log.count('countable', 5)
    assert_equal '5', logged_data['count#test-app.countable']
    assert_equal 'test-deploy', logged_data['source']
  end

  def test_count_with_extra_data
    Vault::Log.count('countable', 1, 'request_id' => 'abc')
    assert_equal '1', logged_data['count#test-app.countable']
    assert_equal 'abc', logged_data['request_id']
  end

  # Vault::Log.count_status emits metrics to measure HTTP responses.
  def test_count_status
    Vault::Log.count_status(201)
    assert_equal '1', logged_data['count#test-app.http.201']
    assert_equal '1', logged_data['count#test-app.http.2xx']
    assert_equal 'test-deploy', logged_data['source']
  end

  def test_measure
    Vault::Log.measure('thinking', 123.4)
    assert_equal '123.400', logged_data['measure#test-app.thinking']
    assert_equal 'test-deploy', logged_data['source']
  end

  def test_measure_with_units
    Vault::Log.measure('thinking', '123.4ms')
    assert_equal '123.4ms', logged_data['measure#test-app.thinking']
  end

  def test_measure_with_extra_data
    Vault::Log.measure('thinking', '123.4', 'request_id' => 'abc')
    assert_equal '123.4', logged_data['measure#test-app.thinking']
    assert_equal 'abc', logged_data['request_id']
  end

  def test_time
    Vault::Log.time('thinking', 123.4)
    assert_equal '123.4ms', logged_data['measure#test-app.thinking']
  end

  # Vault::Log.time emits a metric to measure the duration of an HTTP request.
  # It converts slashes to underscores.
  def test_time_replaces_slash_with_dash
    Vault::Log.time('/some/web/path', 123.4)
    assert_equal '123.4ms', logged_data['measure#test-app.some-web-path']
  end

  def test_time_replaces_underscore_with_dash
    Vault::Log.time('/some/web_path', 123.4)
    assert_equal '123.4ms', logged_data['measure#test-app.some-web-path']
  end

  # Vault::Log.time removes parameters.
  def test_time_removes_parameters
    Vault::Log.time('/some/:web/path', 123.4)
    assert_equal '123.4ms', logged_data['measure#test-app.some-path']
  end

  # Vault::Log.time removes non-alphanumeric characters.
  def test_time_removes_non_alphanumeric_characters
    Vault::Log.time('/some/web+path', 123.4)
    assert_equal '123.4ms', logged_data['measure#test-app.some-webpath']
  end

  # Vault::Log.time is a no-op if a nil name is provided.
  def test_time_without_name
    Vault::Log.time(nil, 123.4)
    assert_equal('', Scrolls.stream.string)
  end

  # Vault::Log.log logs app name in app key by default.
  def test_log_app_name_by_default
    Vault::Log.log(integer: 123)
    assert_equal 'test-app', logged_data['app']
  end

  # Vault::Log.log emits a set of key/value metrics using data from the
  # specified hash.
  def test_log
    Vault::Log.log(integer: 123, float: 123.4, string: 'string', bool: false)
    assert_equal 'test-deploy', logged_data['source']
    assert_equal '123',     logged_data['integer']
    assert_equal '123.400', logged_data['float']
    assert_equal 'string',  logged_data['string']
    assert_equal 'false',   logged_data['bool']
    assert_equal '123.400', logged_data['float']
  end

  # Vault::Log.log can be used to measure the time spent in a block.
  def test_log_with_block
    Vault::Log.log(A: true) do
      Vault::Log.log(B: true)
    end
    assert_equal 'true', logged_data['A']
    assert_equal 'true', logged_data['B']
    assert_equal 'test-deploy', logged_data['source']
    assert_match /\d/, logged_data['elapsed']
  end
end
