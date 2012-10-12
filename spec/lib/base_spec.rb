require 'spec_helper'

describe AuthenticationService::Base do
  before(:each) do
    @sessions_repository    = mock(:sessions_repository)
    @accounts_repository    = mock(:accounts_repository)
    @authentication_service = AuthenticationService::Base.new(@accounts_repository, @sessions_repository)
    
    @account = Account.new(10, "mail@domain.com", "some-password-hash")
    @session = Session.new("session-id", @account, "127.0.0.1", nil, nil)
  end
  
  describe "register_account" do
    it "should use accounts repository to create new account" do
      account = Account.new(10, "mail@domain.com", "some-password-hash")
      @accounts_repository.should_receive(:create).with("mail@domain.com", "some-password").and_return(account)
      
      @authentication_service.register_account "mail@domain.com", "some-password"
    end
    
    it "should return created account instance" do
      account = Account.new(10, "mail@domain.com", "some-password-hash")
      @accounts_repository.stub(:create).and_return(account)
      
      @authentication_service.register_account("mail@domain.com", "some-password").should be account
    end
  end
  
  describe "authenticate_by_session_id" do
    before(:each) do
      @sessions_repository.stub(:find_by_session_id) { @session }
      @sessions_repository.stub(:touch)
    end
    
    it "should use sessions repository to find stored sessions" do
      @sessions_repository.should_receive(:find_by_session_id).with("session-id").and_return(@session)
      @authentication_service.authenticate_by_session_id("session-id", "127.0.0.1")
    end
    
    it "should return nil if session does not exist" do
      @sessions_repository.stub(:find_by_session_id) { nil }
      @authentication_service.authenticate_by_session_id("session-id", "127.0.0.1").should be_nil
    end
    
    it "should return the session if ip_address is the same as initial" do
      @authentication_service.authenticate_by_session_id("session-id", "127.0.0.1").should be @session
    end
    
    it "should return nil if ip_address is different from initial" do
      @authentication_service.authenticate_by_session_id("session-id", "127.0.0.2").should be_nil
    end
    
    it "should touch session so last_time_used_at gets updated" do
      @sessions_repository.should_receive(:touch).with("session-id")
      @authentication_service.authenticate_by_session_id("session-id", "127.0.0.1")
    end
  end
  
  describe "authenticate_by_login" do
    before(:each) do
      @accounts_repository.stub(:find_by_email) { @account }
      Session.stub(:create_new) { @session }
      @sessions_repository.stub(:create) { @session }
      Account.stub(:hash_for_password) { "some-password-hash" }
    end
    
    it "should use accounts repository to obtain accounts" do
      @accounts_repository.should_receive(:find_by_email).with("mail@domain.com").and_return(@account)
      @authentication_service.authenticate_by_login("mail@domain.com", "some-password", "127.0.0.1")
    end
    
    describe "account is found and password is valid" do
      
      it "should return new session instance" do
        @authentication_service.authenticate_by_login("mail@domain.com", "some-password", "127.0.0.1").should be @session
      end

      it "should create new session using sessions repository" do
        @sessions_repository.should_receive(:create).with(@session).and_return(@session)
        @authentication_service.authenticate_by_login("mail@domain.com", "some-password", "127.0.0.1")
      end
    end
    
    it "should return nil if account not found" do
      @accounts_repository.stub(:find_by_email) { nil }
      @authentication_service.authenticate_by_login("mail@domain.com", "some-password", "127.0.0.1").should be_nil
    end
    
    it "should return nil if account is found but password is invalid" do
      Account.stub(:hash_for_password) { "invalid-password-hash" }
      @authentication_service.authenticate_by_login("mail@domain.com", "some-password", "127.0.0.1").should be_nil
    end
  end
  
  describe "sign_out" do
    it "should destroy the session using repository" do
      @sessions_repository.should_receive(:destroy).with(@session).and_return(@session)
      @authentication_service.sign_out(@session)
    end
    
    it "should return session object" do
      @sessions_repository.stub(:destroy) {@session}
      @authentication_service.sign_out(@session).should be @session
    end
  end

  describe "create from options" do
    it "should return instance with configured account and session classes" do
      account_class = mock(:account_class)
      session_class = mock(:session_class)
      authentication_service = described_class.create :account_class => account_class, :session_class => session_class
      authentication_service.accounts_repository.model_class.should be account_class
      authentication_service.sessions_repository.model_class.should be session_class
    end
    
    it "should return instance with configured account and session repositories" do
      accounts_repository = mock(:accounts_repository)
      sessions_repository = mock(:sessions_repository)
      authentication_service = described_class.create :accounts_repository => accounts_repository, :sessions_repository => sessions_repository
      authentication_service.accounts_repository.should be accounts_repository
      authentication_service.sessions_repository.should be sessions_repository
    end

    it "should fail if options does not have account model class or accounts repository instance" do
      session_class = mock(:session_class)
      lambda { 
        described_class.create :account => nil, :accounts_repository => nil, :session => session_class 
      }.should raise_error(RuntimeError)
    end    
    
    it "should fail if options does not have session model class or sessions repository instance" do
      account_class = mock(:account_class)
      lambda {  
        described_class.create :session => nil, :sessions_repository => nil, :account => account_class
      }.should raise_error(RuntimeError)
    end
  end
end
