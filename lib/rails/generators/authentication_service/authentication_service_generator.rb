require 'rails/generators/base'

module AuthenticationService
  module Generators
    class Base < ::Rails::Generators::Base
      def self.base_root
        File.expand_path("../../", __FILE__)
      end
    end
  end
end