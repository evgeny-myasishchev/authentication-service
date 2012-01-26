module AuthenticationService::Rails
  
  def self.included(base)
    base.extend ClassMethods
  end
    
  module ClassMethods
    def authentication_service(options)
      
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
    @authentication_service ||= AuthenticationService::Base.new
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