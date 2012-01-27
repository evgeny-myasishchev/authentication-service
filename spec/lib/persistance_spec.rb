require 'spec_helper'

describe AuthenticationService::Persistance do
  describe AuthenticationService::Persistance::ModelHelpers do
    include AuthenticationService::Persistance::ModelHelpers
    
    describe "to_account_model" do
      it "should create new model instance" do
        rec     = mock :account, :id => 999, :email => "mail@domain.com", :password_hash => "password-hash"
        account = to_account_model(rec)
        account.account_id.should eql rec.id
        account.email.should eql rec.email
        account.password_hash.should eql rec.password_hash
      end
    end

    describe "to_session_model" do
      before(:each) do
        @account = mock :account, :id => 999, :email => "mail@domain.com", :password_hash => "password-hash"
        @session = mock :session, :id => 998, :session_id => "some-session-id", 
          :account => @account, 
          :ip_address => "127.0.0.3",
          :created_at => DateTime.now - 3,
          :updated_at => DateTime.now - 2
      end

      it "should return session model with corresponding properties assigned" do
        model = to_session_model(@session)
        model.should be_instance_of(AuthenticationService::Session)
        model.session_id.should eql @session.session_id
        model.ip_address.should eql @session.ip_address
        model.created_at.should eql @session.created_at
        model.last_time_used_at.should eql @session.updated_at
      end

      it "should also assign account" do
        model = to_session_model(@session)
        model.account.should be_instance_of AuthenticationService::Account
        model.account.email.should eql "mail@domain.com"
      end
    end
  end  
end
