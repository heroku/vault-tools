require 'helper'

class LogTest < Vault::TestCase
  # Vault::Log.count emits a metric, using the specified name, that represents
  # a countable event.
  def test_count
    set_env('APP_NAME', nil)
    Vault::Log.count('countable')
    assert_match(/count#countable=1/, Scrolls.stream.string)
  end

  # Vault::Log.count emits a metric that represents a countable event.  If an
  # APP_NAME environment variable is available it will be prepended to the
  # measurement name.
  def test_count_with_app_name
    set_env('APP_NAME', 'vault_app')
    Vault::Log.count('countable')
    assert_match(/count#vault_app.countable=1/, Scrolls.stream.string)
  end

  # Vault::Log.count_status emits metrics to measure HTTP responses.  The
  # exact HTTP status, and the status family, are recorded.
  def test_count_status
    set_env('APP_NAME', nil)
    Vault::Log.count_status(201)
    assert_match(/count#http_201=1/, Scrolls.stream.string)
    assert_match(/count#http_2xx=1/, Scrolls.stream.string)
  end

  # Vault::Log.count_status emits metrics to measure HTTP responses.  If an
  # APP_NAME environment variable is available it will be prepended to the
  # measurement name.
  def test_count_status_with_app_name
    set_env('APP_NAME', 'vault_app')
    Vault::Log.count_status(201)
    assert_match(/count#vault_app.http_201=1/, Scrolls.stream.string)
    assert_match(/count#vault_app.http_2xx=1/, Scrolls.stream.string)
  end

  # Vault::Log.time emits a metric to measure the duration of an HTTP request.
  # It converts slashes to underscores.
  def test_time_replaces_slash_with_underscore
    Vault::Log.time('/some/web/path', 123.4)
    assert_match(/measure#some_web_path=123.4ms/, Scrolls.stream.string)
  end

  # Vault::Log.time removes parameters.
  def test_time_removes_parameters
    Vault::Log.time('/some/:web/path', 123.4)
    assert_match(/measure#some_path=123.4ms/, Scrolls.stream.string)
  end

  # Vault::Log.time removes non-alphanumeric characters.
  def test_time_removes_non_alphanumeric_characters
    Vault::Log.time('/some/web+path', 123.4)
    assert_match(/measure#some_webpath=123.4ms/, Scrolls.stream.string)
  end

  # Vault::Log.time is a no-op if a nil name is provided.
  def test_time_without_name
    Vault::Log.time(nil, 123.4)
    assert_equal('', Scrolls.stream.string)
  end

  # Vault::Log.log emits a set of key/value metrics using data from the
  # specified hash.
  def test_log
    Vault::Log.log(integer: 123, float: 123.4, string: 'string', bool: false)
    assert_match(/integer=123 float=123.400 string=string bool=false/,
                 Scrolls.stream.string)
  end

  # Vault::Log.log can be used to measure the time spent in a block.
  def test_log_with_block
    Vault::Log.log(A: true) do
      Vault::Log.log(B: true)
    end
    assert_match(/A=true at=start\nB=true\nA=true at=finish elapsed=0/,
                 Scrolls.stream.string)
  end
end
