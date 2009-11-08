class AddAdminModeratorsOrganismPasswords < ActiveRecord::Migration
  def self.up
    add_column :organisms, :admins_password, :string
    add_column :organisms, :moderators_password, :string
  end

  def self.down
    remove_column :organisms, :admins_password
    remove_column :organisms, :moderators_password
  end
end
