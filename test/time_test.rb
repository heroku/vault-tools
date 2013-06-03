require 'helper'

class TimeTest < Vault::TestCase

  # We're always using UTC time
  def test_now_is_utc
    local = Time.local(2012,1,1)
    utc   = Time.utc(2012,1,1)
    assert_equal(utc, local)
  end

  # Default time format is iso8601
  def test_to_s_is_iso8601
    t = Time.utc(2012,1,1)
    assert_equal(t.to_s, t.iso8601)
  end
end
