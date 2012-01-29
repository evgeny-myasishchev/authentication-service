require 'rails/generators/authentication_service/authentication_service_generator'

module AuthenticationService
  module Generators
    class SessionsControllerGenerator < Base
      def create_controller
        template 'sessions_controller.rb', 'app/controllers/sessions_controller.rb'
      end
      
      def create_views
        template 'new.erb', 'app/views/sessions/new.html.erb'
      end
      
      def add_routes
        route %{get "sign-in"   => "sessions#new", :as => :sign_in}
        route %{post "sign-in"  => "sessions#create", :as => :sign_in}
        route %{post "sign-out" => "sessions#destroy", :as => :sign_out}
      end
    end
  end
end