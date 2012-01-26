module AuthenticationService::Rails::SessionsControllerActions
  def self.included(base)
    base.before_filter :authenticate, :only => :destroy
  end
  
  def new
  end

  def create
    authenticated_session = authentication_service.authenticate_by_login(params[:login], params[:password], request.remote_ip)
    if authenticated_session
      session[:authenticated_session_id] = authenticated_session.session_id
      redirect_back
    else
      respond_to do |format|
        format.html {
          render :action => :new, :status => :unauthorized
        }
        format.json {
          render :nothing => true, :status => :unauthorized
        }
      end
    end
  end

  def destroy
    authentication_service.sign_out(current_session)
    reset_session
    respond_to do |format|
      format.html {
        redirect_to(sign_in_url)
      }
      format.json {
        render :json => {'navigate-to' => sign_in_url}
      }
    end
  end
end