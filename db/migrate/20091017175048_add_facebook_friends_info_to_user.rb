class AddFacebookFriendsInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_friends_info, :text
  end

  def self.down
    remove_column :users, :facebook_friends_info
  end
end
