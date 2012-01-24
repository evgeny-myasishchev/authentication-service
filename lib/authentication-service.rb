require "authentication-service/version"

module AuthenticationService
  autoload :Account, 'authentication-service/account'
  autoload :Base, 'authentication-service/base'
  autoload :Persistance, 'authentication-service/persistance'
  autoload :Rails, 'authentication-service/rails'
  autoload :Session, 'authentication-service/session'
end
