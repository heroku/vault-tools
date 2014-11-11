require 'helper'

class StatementStoreTest < Vault::TestCase
  def setup
    super
    StubbedS3.enable!(self)
    StubbedS3.seed('vault-v2-json-invoice-test',
                   '2014-10-01/2014-11-01/user8@heroku.com_v2', '{"foo": 1}')

  end

  def test_invoice_path_with_user_id
    inv = Vault::StatementStore.new(key_id: 'FAKE_ID', key: 'FAKE_KEY')
    path = inv.path_for(start_time: '2014-10-01', stop_time: '2014-11-01',
                        user_id: 7, version: 2)
    assert_equal '2014-10-01/2014-11-01/user7@heroku.com_v2', path
  end

  def test_invoice_path_with_user_hid
    inv = Vault::StatementStore.new(key_id: 'FAKE_ID', key: 'FAKE_KEY')
    path = inv.path_for(start_time: '2014-10-01', stop_time: '2014-11-01',
                        user_hid: 'user8@heroku.com', version: 2)
    assert_equal '2014-10-01/2014-11-01/user8@heroku.com_v2', path
  end

  def test_retrieve_invoice_json
    inv = Vault::StatementStore.new(key_id: 'FAKE_ID', key: 'FAKE_KEY')
    doc = inv.get_json(start_time: '2014-10-01', stop_time: '2014-11-01',
                       user_hid: 'user8@heroku.com', version: 2)
    expected = {"foo" => 1}
    assert_equal expected, doc
  end

  def test_write_invoice_json
    inv = Vault::StatementStore.new(key_id: 'FAKE_ID', key: 'FAKE_KEY')
    # Nothing Before Write
    doc = inv.get_json(start_time: '2014-10-01', stop_time: '2014-11-01',
                       user_hid: 'user9@heroku.com', version: 2)
    expected = nil
    assert_equal expected, doc

    # Write to S3 updating expectation
    expected = {"bar" => 3}
    obj = inv.write_json(start_time: '2014-10-01', stop_time: '2014-11-01',
                         user_hid: 'user9@heroku.com', version: 2,
                         contents: expected)
    assert obj.is_a? StubbedS3::FakeFile

    # There after write
    doc = inv.get_json(start_time: '2014-10-01', stop_time: '2014-11-01',
                       user_hid: 'user9@heroku.com', version: 2)
    assert_equal expected, doc
  end
end
