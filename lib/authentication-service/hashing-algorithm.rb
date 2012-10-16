module AuthenticationService
  class HashingAlgorithm
    def hash_password(password)
      raise "This method should be implemented and return hash for supplied password."
    end

    def self.default
      SHA512.new
    end

    class SHA512 < HashingAlgorithm
      def hash_password(password)
        #Requiring it here because it may not be used if different algorithm is used
        require 'digest/sha2'
        Digest::SHA512.hexdigest(password)
      end
    end
  end
end