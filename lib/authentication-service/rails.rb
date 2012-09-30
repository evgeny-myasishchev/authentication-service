module AuthenticationService::Rails
  
  def self.included(base)
    base.extend ClassMethods
  end
    
  module ClassMethods
    # Using OptionsStore class to preserve values during rails code reload in development mode.
    class OptionsStore
      class << self
        attr_accessor :authentication_service
        attr_accessor :account_class, :session_class
        attr_accessor :accounts_repository, :sessions_repository
      end
    end
    
    def store
      OptionsStore
    end
    
    def account_class
      store.account_class
    end
    
    def session_class
      store.session_class
    end
    
    def accounts_repository
      store.accounts_repository
    end
    
    def sessions_repository
      store.sessions_repository
    end
    
    def authentication_service(options)
      if options.instance_of?(AuthenticationService::Base)
        store.authentication_service = options
        return;
      end

      options = {
        :account => nil,
        :session => nil
      }.merge(options)
      
      raise "Account persistance model class not assigned" unless options[:account] || options[:accounts_repository]
      raise "Session persistance model class not assigned" unless options[:session] || options[:sessions_repository]
      
      OptionsStore.account_class = options[:account]
      OptionsStore.session_class = options[:session]
      
      OptionsStore.accounts_repository = options[:accounts_repository]
      OptionsStore.sessions_repository = options[:sessions_repository]
    end
    
    def behave_as_sessins_controller
      self.send(:include, AuthenticationService::Rails::SessionsControllerActions)
    end
  end
  
  autoload :SessionsControllerActions, 'authentication-service/rails/sessions-controller-actions'
  
  attr_accessor :current_session
  
  def authenticated?
    !current_session.blank?
  end
  
  def authenticate
    authenticate_from_session if session[:authenticated_session_id]
    redirect_not_authenticated unless authenticated?
  end
  
  def authentication_service
    @authentication_service ||= begin
      # return self.class.store.authentication_service unless self.class.store.authentication_service.nil?
      begin
        raise "Authentication service not configured. Please use authentication_service to configure it." 
      end unless self.class.account_class || self.class.accounts_repository
      begin
        raise "Authentication service not configured. Please use authentication_service to configure it."
      end unless self.class.session_class || self.class.sessions_repository
      accounts_repository = self.class.accounts_repository || AuthenticationService::Persistance::AccountsRepository.new(self.class.account_class)
      sessions_repository = self.class.sessions_repository || AuthenticationService::Persistance::SessionsRepository.new(self.class.session_class)
      AuthenticationService::Base.new(accounts_repository, sessions_repository)
    end
  end
  
  def authentication_service=(value)
    @authentication_service = value
  end
  
  protected
    def redirect_not_authenticated
      session[:return_to] = request.fullpath
      redirect_to sign_in_url
    end
  
    def redirect_back
      respond_to do |format|
        format.html {
          redirect_to(session[:return_to] || root_url)
        }
        format.json {
          render :json => {'navigate-to' => (session[:return_to] || root_url)}
        }
      end
      session[:return_to] = nil
    end
  
  private
    def authenticate_from_session
      self.current_session = authentication_service.authenticate_by_session_id(session[:authenticated_session_id], request.remote_ip)
    end
end