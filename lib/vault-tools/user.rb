require 'uuidtools'

module Vault
  module User
    # Convert a user ID into a v5 UUID.
    #
    # @param user_id [Fixnum] A user ID.
    # @return [String] A v5 UUID that uniquely represents the user.
    def self.id_to_uuid(user_id)
      url = "https://vault.heroku.com/users/#{user_id}"
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    end

    # Convert a Heroku user ID into a v5 UUID.
    #
    # @param heroku_id [String] A Heroku user ID, such as
    #   `user1234@heroku.com`.
    # @raise [RuntimeError] Raised if a malformed Heroku ID is provided.
    # @return [String] A v5 UUID that uniquely represents the user.
    def self.hid_to_uuid(heroku_id)
      if user_id = heroku_id.slice(/^user(\d+)\@heroku\.com$/, 1)
        id_to_uuid(user_id)
      else
        raise "#{heroku_id} is not a valid Heroku user ID."
      end
    end
  end
end
