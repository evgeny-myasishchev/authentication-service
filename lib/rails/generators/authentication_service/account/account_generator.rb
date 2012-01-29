require 'rails/generators/active_record/migration'
require 'active_record'
require 'rails/generators/authentication_service/authentication_service_generator'

module AuthenticationService
  module Generators
    class AccountGenerator < Base
      include ::Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration
      
      def create_module_file
        template '../../templates/persistance_module.rb', 'app/models/persistance.rb'
      end
      
      def create_model_file
        template 'account.rb', 'app/models/persistance/account.rb'
      end
      
      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_persistance_accounts.rb'
      end
    end
  end
end