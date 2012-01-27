module AuthenticationService::Persistance
  class SessionsRepository
    include AuthenticationService::Persistance::ModelHelpers
    
    def initialize(model_class)
      @model_class = model_class
    end
    
    def find_by_session_id(session_id)
      rec = @model_class.includes(:account).find_by_session_id(session_id)
      return nil unless rec
      return to_session_model rec
    end

    def create(session)
      @model_class.create! :session_id => session.session_id,
        :account_id => session.account.account_id,
        :ip_address => session.ip_address,
        :created_at => session.created_at,
        :updated_at => session.last_time_used_at
      session
    end

    def touch(session_id)
      rec = @model_class.find_by_session_id(session_id)
      rec.touch
    end

    def destroy(session)
      rec = @model_class.find_by_session_id(session.session_id)
      rec.destroy
      session
    end    
  end
end