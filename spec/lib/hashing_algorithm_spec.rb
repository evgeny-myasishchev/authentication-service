require 'spec_helper'

describe AuthenticationService::HashingAlgorithm do
  describe "hash_pasword" do
    it "should be not implemented" do
      lambda { subject.hash_password("some password") }.should raise_error
    end
  end

  describe "default" do
    it "should be SHA512" do
      described_class.default.should be_instance_of AuthenticationService::HashingAlgorithm::SHA512
    end
  end

  describe AuthenticationService::HashingAlgorithm::SHA512 do
    subject { AuthenticationService::HashingAlgorithm::SHA512.new }

    describe "hash_password" do
      it "should use Digest::SHA512 to hash passwords" do
        Digest::SHA512.should_receive(:hexdigest).with("password to hash") { "resulting hash" }        
        subject.hash_password("password to hash").should eql "resulting hash"
      end
    end
  end
end