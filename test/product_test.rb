require 'helper'
require 'uuidtools'

class ProductTest < Vault::TestCase
  # Product.name_to_uuid converts a product name to a v5 UUID based on a URL
  # scheme.
  def test_name_to_uuid
    url = 'https://vault.heroku.com/products/platform:dyno:logical'
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    assert_equal(uuid, Vault::Product.name_to_uuid('platform:dyno:logical'))
  end

  # Product.name_to_uuid raises a RuntimeError if an empty name is provided.
  def test_name_to_uuid_with_empty_name
    error = assert_raises(RuntimeError) do
      Vault::Product.name_to_uuid('')
    end
    assert_equal("Product name empty or contains illegal characters.",
                 error.message)
  end

  # Product.name_to_uuid raises a RuntimeError if the product name contains
  # illegal characters.
  def test_name_to_uuid_with_illegal_characters
    assert_raises(RuntimeError) { Vault::Product.name_to_uuid('!') }
    assert_raises(RuntimeError) { Vault::Product.name_to_uuid(' ') }
    assert_raises(RuntimeError) { Vault::Product.name_to_uuid('A') }
  end
end
