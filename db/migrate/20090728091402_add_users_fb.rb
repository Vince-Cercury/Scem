class AddUsersFb < ActiveRecord::Migration
  def self.up
    remove_column :users, :name
    add_column :users, :first_name,    :string, :limit => 100 # , :default => '', :null => true
    add_column :users, :last_name,     :string, :limit => 100 # , :default => '', :null => true
    add_column :users, :date_of_birth, :datetime
    add_column :users, :fb_user_id, :integer
    add_column :users, :email_hash, :string
    #if mysql
    execute("alter table users modify fb_user_id bigint")
  end

  def self.down
    add_column :users, :name, :string
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :date_of_birth
    remove_column :users, :fb_user_id
    remove_column :users, :email_hash
  end

end
