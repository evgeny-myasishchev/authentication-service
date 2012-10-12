class AuthenticationService::Base
  attr_reader :accounts_repository, :sessions_repository
  
  def initialize(accounts_repository, sessions_repository)
    @accounts_repository = accounts_repository
    @sessions_repository = sessions_repository
  end
  
  def register_account(email, password)
    accounts_repository.create(email, password)
  end
  
  #
  # Returns Session instance if it exists and is valid
  #
  def authenticate_by_session_id(session_id, ip_address)
    session = sessions_repository.find_by_session_id(session_id)
    return nil unless session
    return nil unless session.ip_address == ip_address
    sessions_repository.touch session.session_id
    return session
  end
  
  #
  # Validates login/password and returns new Session instance
  # Login is email
  #
  def authenticate_by_login(login, password, ip_address)
    account = accounts_repository.find_by_email(login)
    return nil unless account
    
    password_hash = AuthenticationService::Account.hash_for_password(password)
    return nil unless account.password_hash == password_hash
    
    sessions_repository.create AuthenticationService::Session.create_new(account, ip_address)
  end
  
  def sign_out(session)
    sessions_repository.destroy(session)
  end  

  def self.create(options)
    raise "Account persistance model class or repository is not assigned" unless options[:account_class] || options[:accounts_repository]
    raise "Session persistance model class or repository is not assigned" unless options[:session_class] || options[:sessions_repository]

    accounts_repository = options[:accounts_repository] || AuthenticationService::Persistance::AccountsRepository.new(options[:account_class])
    sessions_repository = options[:sessions_repository] || AuthenticationService::Persistance::SessionsRepository.new(options[:session_class])

    new(accounts_repository, sessions_repository)
  end
end