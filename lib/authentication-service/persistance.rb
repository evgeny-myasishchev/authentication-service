module AuthenticationService::Persistance
  autoload :AccountsRepository, 'authentication-service/persistance/accounts-repository'
  autoload :SessionsRepository, 'authentication-service/persistance/sessions-repository'
  
  
  module ModelHelpers
    def to_session_model(session_record)
      AuthenticationService::Session.new(session_record.session_id, 
        to_account_model(session_record.account), 
        session_record.ip_address, 
        session_record.created_at, 
        session_record.updated_at)
    end

    def to_account_model(account_record)
      AuthenticationService::Account.new account_record.id, account_record.email, account_record.password_hash
    end
  end  
end