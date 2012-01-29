class CreatePersistanceSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_id, :null => false, :limit => 255
      t.integer :account_id, :null => false
      t.string :ip_address, :null => false, :limit => 100
      t.timestamps
    end
    
    add_index :sessions, [:account_id]
    add_index :sessions, [:session_id], :unique => true
  end
end