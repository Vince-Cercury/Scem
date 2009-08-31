class CreateOrganismsUsers < ActiveRecord::Migration
  def self.up
    create_table("organisms_users") do |t|
      t.integer :organism_id
      t.integer :user_id
      t.string  :role
    end
    add_index :organisms_users, :organism_id
    add_index :organisms_users, :user_id
  end

  def self.down
    drop_table "organisms_users"
  end
end
