module AuthenticationService::Persistance
  class AccountsRepository
    include AuthenticationService::Persistance::ModelHelpers
    
    attr_reader :model_class, :hashing_algorithm
    
    def initialize(model_class, hashing_algorithm)
      @model_class = model_class
      @hashing_algorithm = hashing_algorithm
    end
    
    def create(email, password)
      rec = @model_class.create! :email => email, :password_hash => hashing_algorithm.hash_password(password)
      to_account_model rec
    end

    def find_by_email(email)
      rec = @model_class.find_by_email(email)
      return nil unless rec
      to_account_model rec
    end    
  end
end