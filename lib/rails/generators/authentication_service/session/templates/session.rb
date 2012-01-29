class Persistance::Session < ActiveRecord::Base
  belongs_to :account
end
