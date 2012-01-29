class CreatePersistanceAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email, :limit => 255, :null => false
      t.string :password_hash, :limit => 1024, :null => false

      t.timestamps
    end
    
    add_index :accounts, [:email], :unique => true
  end
end
