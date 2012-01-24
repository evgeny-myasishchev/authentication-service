require 'spec_helper'

describe Account do
  describe "hash_for_password" do
    it "should use SHA512 as hashing method" do
      sha512_hash = Digest::SHA512.hexdigest('some-password')
      Account.hash_for_password('some-password').should eql sha512_hash
    end
  end
end