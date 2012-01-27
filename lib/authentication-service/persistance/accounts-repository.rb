module AuthenticationService::Persistance
  class AccountsRepository
    include AuthenticationService::Persistance::ModelHelpers
    
    def initialize(model_class)
      @model_class = model_class
    end
    
    def create(email, password)
      rec = @model_class.create! :email => email, :password_hash => AuthenticationService::Account.hash_for_password(password)
      to_account_model rec
    end

    def find_by_email(email)
      rec = @model_class.find_by_email(email)
      return nil unless rec
      to_account_model rec
    end    
  end
end