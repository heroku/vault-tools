require 'helper'
require 'uuidtools'

class AppTest < Vault::TestCase
  # App.id_to_uuid converts app IDs to a v5 UUID based on a URL scheme.
  def test_id_to_uuid
    url = "https://vault.heroku.com/apps/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::App.id_to_uuid(1234))
  end

  # App.hid_to_uuid converts Heroku app IDs to a v5 UUID based on a URL
  # scheme.
  def test_hid_to_uuid
    url = "https://vault.heroku.com/apps/1234"
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::App.hid_to_uuid('app1234@heroku.com'))
  end

  # App.hid_to_uuid raises a RuntimeError if the specified ID doesn't match
  # the expected format.
  def test_hid_to_uuid_with_invalid_heroku_id
    error = assert_raises(RuntimeError) do
      Vault::App.hid_to_uuid('invalid1234@heroku.com')
    end
    assert_equal('invalid1234@heroku.com is not a valid Heroku app ID.',
                 error.message)
  end
end
