require 'rails/generators/authentication_service/authentication_service_generator'

module AuthenticationService
  module Generators
    class SessionsControllerGenerator < Base
      def generate_something
        puts "Hello"
      end
    end
  end
end