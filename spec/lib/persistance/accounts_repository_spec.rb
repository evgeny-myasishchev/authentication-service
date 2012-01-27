require 'spec_helper'

describe AuthenticationService::Persistance::AccountsRepository do
  before(:each) do
    @model_class = mock(:account_model_class)
    @repository  = AuthenticationService::Persistance::AccountsRepository.new @model_class
  end
  
  describe "create" do
    it "should create corresponding database record" do
      password_hash = AuthenticationService::Account.hash_for_password("some-password")
      @model_class.should_receive(:create!).
        with(:email => "mail@domain.com", :password_hash => password_hash).
        and_return(mock(:account_rec, :id => 999, :email => "mail@domain.com", :password_hash => password_hash))
      @repository.create "mail@domain.com", "some-password"
    end
    
    it "return Account instance" do
      password_hash = AuthenticationService::Account.hash_for_password("some-password")
      @model_class.stub(:create!).
        and_return(mock(:account_rec, :id => 999, :email => "mail@domain.com", :password_hash => password_hash))
      account = @repository.create "mail@domain.com", "some-password"
      account.should be_instance_of AuthenticationService::Account
      account.account_id.should eql 999
      account.email.should eql "mail@domain.com"
    end
    
    it "should hash password" do
      AuthenticationService::Account.should_receive(:hash_for_password).with("some-password").and_return("hashed-password")
      @model_class.stub(:create!).
        and_return(mock(:account_rec, :id => 999, :email => "mail@domain.com", :password_hash => "hashed-password"))
      account = @repository.create "mail@domain.com", "some-password"
      account.password_hash.should eql "hashed-password"
    end
  end
  
  describe "find_by_email" do
    it "should return corresponding database record searching by email" do
      rec = mock :account_rec, :id => 999, :email => "mail@domain.com", :password_hash => "some-hash"
      @model_class.should_receive(:find_by_email).with("mail@domain.com").and_return(rec)
      
      account = @repository.find_by_email rec.email
      account.account_id.should eql rec.id
      account.password_hash.should eql rec.password_hash
    end
    
    it "should return nil if no such account" do
      @model_class.should_receive(:find_by_email).with("unknown-mail@domain.com").and_return(nil)
      @repository.find_by_email("unknown-mail@domain.com").should be_nil
    end
  end
end
