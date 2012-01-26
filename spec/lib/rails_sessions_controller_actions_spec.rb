require 'spec_helper'

class RailsSessionsControllerActionsSpecController
  
  class << self
    attr_accessor :before_filter_args
    def before_filter(sym, options)
      @before_filter_args = {
        :sym => sym,
        :options => options
      }
    end
  end
  
  include AuthenticationService::Rails::SessionsControllerActions
  
  attr_reader :session
  attr_accessor :authentication_service, :current_session, :request, :params
  
  def initialize
    @session = {}
  end
end

describe RailsSessionsControllerActionsSpecController do
  
  before(:each) do
    @session                           = mock(:session)
    @authentication_service            = mock(:authentication_service)
    @controller                        = RailsSessionsControllerActionsSpecController.new
    @controller.request                = mock(:request)
    @controller.authentication_service = @authentication_service
    
    @controller.stub(:redirect_back)
    @controller.request.stub("remote_ip") { "localhost" }
    @session.stub(:session_id) { "some-session-id" }
  end
  
  describe "module included" do
    it "should define filter :authenticate for destroy action" do
      @controller.class.before_filter_args[:sym].should eql :authenticate
      @controller.class.before_filter_args[:options][:only].should eql :destroy
    end
  end

  describe "new" do
    it "should do nothing" do
      @controller.new
    end
  end

  describe "create" do
    describe "authentication successful" do
      it "uses authentication_service to create new session" do
        @authentication_service.should_receive(:authenticate_by_login).with("admin", "password", "localhost").and_return(@session)
        
        @controller.params = {
          :login => "admin",
          :password => "password"
        }
        @controller.create
      end
      
      it "remembers new session_id in session" do
        @authentication_service.stub(:authenticate_by_login).and_return(@session)
        
        @controller.params = {
          :login => "admin",
          :password => "password"
        }
        @controller.create
        
        @controller.session[:authenticated_session_id].should eql "some-session-id"
      end

      it "redirects redirect_back" do
        @authentication_service.stub(:authenticate_by_login).and_return(@session)
        
        @controller.should_receive :redirect_back
        
        @controller.params = {
          :login => "admin",
          :password => "password"
        }
        @controller.create
      end
    end
    
    describe "authentication failed" do
      before(:each) do
        @authentication_service.stub(:authenticate_by_login).and_return(nil)
        @format = mock(:format)
        @format.stub(:json)
        @format.stub(:html)
        @controller.should_receive(:respond_to) do |&block| block.call(@format) end        
      end
      
      describe "for html format" do
        it "should render :new and return unauthorized status" do
          @format.should_receive(:html) do |&block| block.call end
            
          @controller.should_receive(:render).with(:action => :new, :status => :unauthorized)

          @controller.params = {
            :login => "admin",
            :password => "password"
          }
          @controller.create
        end        
      end
      
      describe "for json format" do
        it "should render :nothing and return unauthorized status" do
          @format.should_receive(:json) do |&block| block.call end
            
          @controller.should_receive(:render).with(:nothing => true, :status => :unauthorized)

          @controller.params = {
            :login => "admin",
            :password => "password"
          }
          @controller.create
        end
      end
    end
  end

  describe "POST 'destroy'" do
    before(:each) do
      @format = mock(:format)
      @format.stub(:json)
      @format.stub(:html)
      @controller.should_receive(:respond_to) do |&block| block.call(@format) end        

      @controller.current_session = @session
      @authentication_service.stub(:sign_out)
      
      @controller.stub(:sign_in_url) { '/sign-in' }
      @controller.stub(:reset_session)
    end
    
    it "should use authentication_service to sign-off" do
      @authentication_service.should_receive(:sign_out).with(@session)
      @controller.destroy
    end
    
    it "should reset session" do
      @controller.should_receive(:reset_session)
      
      @controller.destroy
    end
    
    describe "for html" do
      it "should redirect to sign_in_url" do
        @format.should_receive(:html) do |&block| block.call end
        @controller.should_receive(:redirect_to).with("/sign-in")
        @controller.destroy
      end
    end
    
    describe "for json" do
      it "should render json with sign_in_url" do
        @format.should_receive(:json) do |&block| block.call end
        @controller.should_receive(:render).with(:json => {'navigate-to' => '/sign-in'})
        @controller.destroy
      end
    end
  end
end
