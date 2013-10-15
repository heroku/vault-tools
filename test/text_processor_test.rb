require 'helper'

class TextProcessorTest < Vault::TestCase
  def setup
    set_env 'FERNET_SECRET', 'Mcdej7RFV/yHDrs1P8mrYP9zcw4JxSyReqYyELDrRPY='
  end

  def test_roundtrip
    string = 'foo'
    write = Vault::Tools::TextEnc::Write.process(string)
    read  = Vault::Tools::TextEnc::Read.process(write)
    assert_equal string, read
  end

  def test_roundtrip2
    string = 'foo'
    write = Vault::Tools::TextEnc.write(string)
    read  = Vault::Tools::TextEnc.read(write)
    assert_equal string, read
  end

  def test_write_is_smaller_size
    string = 'foo' * 100
    write = Vault::Tools::TextEnc::Write.process(string)
    assert string.size > write.size, "Written String should be smaller than raw string"
  end

  def test_easy_named_functions

  end
end
