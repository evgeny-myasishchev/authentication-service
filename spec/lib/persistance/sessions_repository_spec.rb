require 'spec_helper'

describe AuthenticationService::Persistance::SessionsRepository do
  include AuthenticationService::Persistance::ModelHelpers
  
  before(:each) do
    @model_class = mock(:session_model_class)
    @repository  = AuthenticationService::Persistance::SessionsRepository.new(@model_class)
    @account_rec = mock :account_rec, :id => 999, :email => "mail@domain.com", :password_hash => "password-hash"
    @session_rec = mock :session_rec, 
      :id         => 555, 
      :session_id => "unique-session-id", 
      :account_id => @account_rec.id, 
      :account    => @account_rec,
      :ip_address => "127.0.0.2",
      :created_at => DateTime.now,
      :updated_at => DateTime.now
  end
  
  describe "find_by_session_id" do
    before(:each) do
      @model_class.stub(:includes) { @model_class }
      @model_class.stub(:find_by_session_id) { @session_rec }
    end
    
    it "should return corresponding session instance" do
      @model_class.should_receive(:includes).with(:account) { @model_class }
      @model_class.should_receive(:find_by_session_id).with("unique-session-id") { @session_rec }

      session = @repository.find_by_session_id "unique-session-id"
      session.should be_instance_of AuthenticationService::Session
      session.ip_address.should eql "127.0.0.2"
    end
    
    it "should return nil for not existing session_id" do
      @model_class.stub(:find_by_session_id) { nil }
      @repository.find_by_session_id("unknown-session-id").should be_nil
    end
    
    it "should assign corresponding account" do
      session = @repository.find_by_session_id "unique-session-id"
      session.account.should_not be_nil
      session.account.should be_instance_of AuthenticationService::Account
      session.account.account_id.should eql @account_rec.id
    end
  end
  
  describe "create" do
    it "should create corresponding database record" do
      session = AuthenticationService::Session.create_new to_account_model(@account_rec), "127.0.0.1"
      @model_class.should_receive(:create!).with(:session_id => session.session_id,
        :account_id => session.account.account_id,
        :ip_address => session.ip_address,
        :created_at => session.created_at,
        :updated_at => session.last_time_used_at)
        
      @repository.create session
    end
    
    it "should return created session instance" do
      new_session = AuthenticationService::Session.create_new to_account_model(@account_rec), "127.0.0.1"
      @model_class.stub(:create!)
      session = @repository.create new_session
      session.should be(new_session)
    end
  end
  
  describe "touch" do
    it "should set updated_at date to now" do
      @model_class.should_receive(:find_by_session_id).with(@session_rec.session_id).and_return(@session_rec)
      @session_rec.should_receive :touch
      @repository.touch @session_rec.session_id
    end
  end  
  
  describe "destroy" do
    before(:each) do
      @session = to_session_model(@session_rec)
    end
    
    it "should destroy sessions record" do
      @model_class.should_receive(:find_by_session_id).with(@session_rec.session_id).and_return(@session_rec)
      @session_rec.should_receive(:destroy)
      @repository.destroy(@session)
    end
        
    it "should return sessions model" do
      @model_class.stub(:find_by_session_id).and_return(@session_rec)
      @session_rec.stub(:destroy)
      @repository.destroy(@session).should be @session
    end
  end
end
