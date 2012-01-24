class AuthenticationService::Session
  attr_reader :session_id

  #Account instance of this session
  attr_reader :account

  #Ip address of the client that has issued the session
  attr_reader :ip_address

  #Date/Time when session has been started
  attr_reader :created_at

  #Date/Time when the session has been used last time
  attr_reader :last_time_used_at

  def initialize(session_id, account, ip_address, created_at, last_time_used_at)
    @session_id, @account, @ip_address, @created_at, @last_time_used_at = session_id, account, ip_address, created_at, last_time_used_at
  end

  # Make sure the session has not expired and ip_address is the same as originally issued
  def is_valid?(ip_address)

  end

  class << self
    def create_new(account, ip_address)
      new(SecureRandom.hex(32), account, ip_address, DateTime.now, DateTime.now)
    end
  end
end