require 'digest/sha2'

class AuthenticationService::Account
  attr_reader :account_id
  attr_accessor :email, :password_hash

  def initialize(account_id, email, password_hash)
    @account_id, @email, @password_hash = account_id, email, password_hash
  end

  class << self

    def hash_for_password(password)
      Digest::SHA512.hexdigest(password)
    end
  end
end