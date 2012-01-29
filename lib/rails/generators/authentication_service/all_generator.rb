require 'rails/generators/authentication_service/authentication_service_generator'

module AuthenticationService
  module Generators
    class All < Base
      def generate_all
        ::Rails::Generators.invoke("authentication_service:account")
        ::Rails::Generators.invoke("authentication_service:session")
        ::Rails::Generators.invoke("authentication_service:sessions_controller")
      end
    end
  end
end