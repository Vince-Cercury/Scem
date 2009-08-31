class AddOrganismsUsersStatePass < ActiveRecord::Migration
  def self.up
    add_column :organisms_users, :state, :string, :null => :no, :default => "passive"
    add_column :organisms_users, :password_member, :string
    add_column :organisms_users, :activated_at, :datetime
  end

  def self.down
    remove_column :organisms_users, :state
    remove_column :organisms_users, :password_member
    remove_column :organisms_users, :activated_at
  end
end
