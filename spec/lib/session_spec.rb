require 'spec_helper'

describe Session do
  describe "create_new" do
    it "should assign account and ip_address" do
      account  = mock(:account)
      session = Session.create_new(account, "localhost")
      session.account.should be account
      session.ip_address.should eql "localhost"
    end
    
    it "should generate new random session_id" do
      session1 = Session.create_new(mock(:account), "localhost")
      session2 = Session.create_new(mock(:account), "localhost")
      
      session1.session_id.should_not be_nil
      session2.session_id.should_not be_nil
      
      session1.session_id.should_not eql session2.session_id
    end
  end
end
