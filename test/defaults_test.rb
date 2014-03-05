require 'helper'

class DefaultsTest < Vault::TestCase
  include Vault::Test::EnvironmentHelpers

  def setup
    Config.defaults.clear
  end

  def test_default_when_no_value
    assert_equal(Config[:max_connections], nil)
    Config.default(:max_connections, 10)
    assert_equal(Config[:max_connections], 10)
  end

  def test_default_with_int
    assert_equal(Config[:max_connections], nil)
    Config.default(:max_connections, '10')
    assert_equal('10', Config[:max_connections])
    assert_equal(10, Config.int(:max_connections))
    set_env 'MAX_CONNECTIONS', '100'
    assert_equal(100, Config.int(:max_connections))
  end

  def test_default_with_time
    assert_equal(Config[:date], nil)
    Config.default(:date, '2013-01-01')
    assert_equal('2013-01-01', Config[:date])
    assert_equal(Time.utc(2013), Config.time(:date))
    set_env 'DATE', '2014-01-01'
    assert_equal('2014-01-01', Config[:date])
    assert_equal(Time.utc(2014), Config.time(:date))
  end

  def test_default_with_array
    assert_equal(Config[:array], nil)
    Config.default(:array, '10')
    assert_equal('10', Config[:array])
    assert_equal(['10'], Config.array(:array))
    Config.default(:array, '1,0')
    assert_equal('1,0', Config[:array])
    assert_equal(['1','0'], Config.array(:array))
    set_env 'ARRAY', '1,2'
    assert_equal('1,2', Config[:array])
    assert_equal(['1','2'], Config.array(:array))
  end
end
