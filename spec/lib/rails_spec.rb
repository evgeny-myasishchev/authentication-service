require 'spec_helper'

class AuthenticationSpecController
  include AuthenticationService::Rails

  # authentication_service { :sign_in_action => '/sign-in', 
  #   :sign_out_action => '/sign-out'}
  
  attr_reader :session
  attr_accessor :request
  
  def initialize
    @session = {}
  end
  
  attr_accessor :respond_to_format
  def respond_to(&block)
    yield(@respond_to_format)
  end
end

describe AuthenticationService::Rails do
  before(:each) do
    @controller         = AuthenticationSpecController.new
    @controller.request = mock(:request)
  end
  
  before(:each) do
    @authentication_service            = mock(:authentication_service)
    @controller.authentication_service = @authentication_service
  end
  
  describe "authenticated?" do
    it "should return true if current sesion is not nil" do
      @controller.current_session = mock(:session, :blank? => false)
      @controller.authenticated?.should be_true
    end
    
    it "should return false if current session is nil" do
      @controller.current_session = mock(:session, :blank? => true)
      @controller.authenticated?.should be_false
    end
  end
  
  describe "authenticate" do
    it "should authenticate_from_session if there is authenticated session id" do
      @controller.session[:authenticated_session_id] = "some-session-id"
      @controller.should_receive(:authenticate_from_session) {
        @controller.current_session = mock(:session, :blank? => false)
      }
      @controller.should_not_receive(:redirect_not_authenticated)
      @controller.authenticate
    end
    
    it "should redirect_not_authenticated if not authenticated" do
      @controller.current_session = mock(:session, :blank? => true)
      @controller.should_receive(:redirect_not_authenticated)
      @controller.authenticate
    end
    
    it "should not redirect if authenticated" do
      @controller.current_session = mock(:session, :blank? => false)
      @controller.should_not_receive(:redirect_not_authenticated)
      @controller.authenticate      
    end
  end
  
  describe "authenticate_from_session" do
    before(:each) do
      @controller.authentication_service             = mock(:authentication_service)
      @controller.session[:authenticated_session_id] = "authenticated-session-id"
      @controller.request.stub(:remote_ip).and_return("192.168.48.1")
    end
    
    it "uses authentication-service to authenticate by session-id" do
      @controller.request.should_receive(:remote_ip).and_return("192.168.48.1")
      @controller.authentication_service.should_receive(:authenticate_by_session_id).with("authenticated-session-id", "192.168.48.1")
      @controller.send(:authenticate_from_session)
    end
    
    it "assigns current_session" do
      authenticated_session = mock(:authenticated_session)
      @controller.authentication_service.
        should_receive(:authenticate_by_session_id).
        with("authenticated-session-id", "192.168.48.1").
        and_return(authenticated_session)
      @controller.send(:authenticate_from_session)
      @controller.current_session.should be authenticated_session
    end
  end
  
  describe "redirect_not_authenticated" do
    before(:each) do
      @controller.request.should_receive(:fullpath).and_return('/current-path')
      @controller.should_receive(:sign_in_url).and_return("/sign-in")
      @controller.stub(:redirect_to)
    end
    
    it "should remember current path in session" do
      @controller.send(:redirect_not_authenticated)
      @controller.session[:return_to].should eql '/current-path'
    end
    
    it "should redirect to sign_in_url" do
      @controller.should_receive(:redirect_to).with("/sign-in")
      @controller.send(:redirect_not_authenticated)
    end
  end
  
  describe "redirect_back" do
    before(:each) do
      @format = mock(:format)
      @format.stub(:html)
      @format.stub(:json)
      @controller.respond_to_format = @format
    end
    
    describe "for html format" do
      before(:each) do
        @format.should_receive(:html) do |&block| block.call end        
      end
      
      it "should redirect to previously saved return path" do
        @controller.session[:return_to] = "/return-path"
        @controller.should_receive(:redirect_to).with("/return-path")
        @controller.send(:redirect_back)
      end
      
      it "should redirect to root_url if no saved return path" do
        @controller.should_receive(:root_url).and_return("/root-url")
        @controller.should_receive(:redirect_to).with("/root-url")
        @controller.send(:redirect_back)
      end
      
      it "should clear saved return path" do
        @controller.session[:return_to] = "/return-path"
        @controller.stub(:redirect_to)
        @controller.send(:redirect_back)
        @controller.session[:return_to].should be_nil
      end
    end
    
    describe "for json format" do
      before(:each) do
        @format.should_receive(:json) do |&block| block.call end        
      end
      
      it "should render json with previously saved return path" do
        @controller.session[:return_to] = "/return-path"
        @controller.should_receive(:render) do |rendered_with|
          rendered_with[:json]['navigate-to'].should eql '/return-path'
        end
        @controller.send(:redirect_back)
      end
      
      it "should render json with root_url if no saved return path" do
        @controller.should_receive(:root_url).and_return("/root-url")
        @controller.should_receive(:render) do |rendered_with|
          rendered_with[:json]['navigate-to'].should eql '/root-url'
        end
        @controller.send(:redirect_back)
      end
      
      it "should clear saved return path" do
        @controller.session[:return_to] = "/return-path"
        @controller.stub(:render)
        @controller.send(:redirect_back)
        @controller.session[:return_to].should be_nil
      end
    end
  end
end
