module AuthenticationService::Persistance
  class SessionsRepository
    def find_by_session_id(session_id)
      raise "Not implemented"
    end

    def create(session)
      raise "Not implemented"
    end

    def touch(session_id)
      raise "Not implemented"
    end

    def destroy(session)
      raise "Not implemented"
    end    
  end
end