require 'helper'
require 'uuidtools'

class UserTest < Vault::TestCase
  # User.id_to_hid converts a user ID to a Heroku user ID.
  def test_id_to_hid
    assert_equal('user1234@heroku.com', Vault::User.id_to_hid(1234))
  end

  # User.id_to_uuid converts a user ID to a v5 UUID based on a URL scheme.
  def test_id_to_uuid
    url = "https://vault.heroku.com/users/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::User.id_to_uuid(1234))
  end

  # User.hid_to_id converts a Heroku user ID into a core integer user ID.
  def test_hid_to_id
    assert_equal(1234, Vault::User.hid_to_id('user1234@heroku.com'))
  end

  # User.hid_to_id raises an ArgumentError if the specified ID doesn't match
  # the expected format.
  def test_hid_to_id_with_invalid_heroku_id
    error = assert_raises(ArgumentError) do
      Vault::User.hid_to_id('invalid1234@heroku.com')
    end
    assert_equal('invalid1234@heroku.com is not a valid Heroku user ID.',
                 error.message)
  end

  # User.hid_to_uuid converts a Heroku user ID to a v5 UUID based on a URL
  # scheme.
  def test_hid_to_uuid
    url = "https://vault.heroku.com/users/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::User.hid_to_uuid('user1234@heroku.com'))
  end

  # User.hid_to_uuid raises an ArgumentError if the specified ID doesn't match
  # the expected format.
  def test_hid_to_uuid_with_invalid_heroku_id
    error = assert_raises(ArgumentError) do
      Vault::User.hid_to_uuid('invalid1234@heroku.com')
    end
    assert_equal('invalid1234@heroku.com is not a valid Heroku user ID.',
                 error.message)
  end
end
