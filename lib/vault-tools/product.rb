require 'uuidtools'

module Vault
  module Product
    # Convert a product name into a v5 UUID.
    #
    # @param name [String] A product name.
    # @raise [RuntimeError] Raised if the product name is empty or contains
    #   illegal characters.  A product name may only contain 'a-z', '0-9' and
    #   ':' characters.
    # @return [String] A v5 UUID that uniquely represents the product.
    def self.name_to_uuid(name)
      unless name =~ /[a-z,0-9]+/
        raise "Product name empty or contains illegal characters."
      end
      url = "https://vault.heroku.com/products/#{name}"
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    end
  end
end
