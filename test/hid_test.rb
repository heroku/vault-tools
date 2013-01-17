require 'helper'
require 'uuidtools'

class HIDTest < Vault::TestCase

  # HID.hid_to_uuid converts an app ID to a v5 UUID based on a URL scheme.
  def test_app_id_to_uuid
    url = "https://vault.heroku.com/apps/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::HID.hid_to_uuid('app1234@heroku.com'))
  end

  # HID.hid_to_uuid converts a Heroku app ID to a v5 UUID based on a URL
  # scheme.
  def test_user_id_to_uuid
    url = "https://vault.heroku.com/users/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::HID.hid_to_uuid('user1234@heroku.com'))
  end

  # HID.hid_to_uuid raises a ArgumentError if the specified ID doesn't match
  # the expected format.
  def test_hid_to_uuid_with_invalid_heroku_id
    error = assert_raises(ArgumentError) do
      Vault::HID.hid_to_uuid('invalid1234@heroku.com')
    end
    assert_equal('invalid1234@heroku.com is not a valid Heroku app or user ID.',
                 error.message)
  end

  # HID.hid_to_uuid raises a ArgumentError if the specified ID doesn't match
  # the expected format.
  def test_hid_to_uuid_with_subtly_invalid_heroku_id
    error = assert_raises(ArgumentError) do
      Vault::HID.hid_to_uuid('app1234--afasd-afas')
    end
    assert_equal('app1234--afasd-afas is not a valid Heroku app ID.',
                 error.message)
  end
end
