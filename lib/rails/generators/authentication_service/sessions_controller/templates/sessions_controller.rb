class SessionsController < ApplicationController
  # behave_as_sessins_controller injects following actions:
  # GET new
  # POST create, params: login(email), password
  # POST destroy
  # 
  # Please see module source 'AuthenticationService::Rails::SessionsControllerActions' for details
  behave_as_sessins_controller
end