module AuthenticationService
  class Engine < Rails::Engine
    config.authentication_service = ActiveSupport::OrderedOptions.new

    initializer "authentication-service" do |app|      
      app.authentication_service = AuthenticationService::Base.create(config.authentication_service) if app.authentication_service.nil?
    end
  end
end

Rails::Application.class_eval do
  attr_accessor :authentication_service
end