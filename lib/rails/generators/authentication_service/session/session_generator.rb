require 'rails/generators/active_record/migration'
require 'active_record'
require 'rails/generators/authentication_service/authentication_service_generator'

module AuthenticationService
  module Generators
    class SessionGenerator < Base
      include ::Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration
      
      def create_module_file
        template '../../templates/persistance_module.rb', 'app/models/persistance.rb'
      end
      
      def create_model_file
        template 'session.rb', 'app/models/persistance/session.rb'
      end
      
      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_persistance_sessions.rb'
      end
    end
  end
end