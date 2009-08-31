class AddEventModerateComments < ActiveRecord::Migration
  def self.up
    add_column :events, :receive_comment_notification, :boolean, :null => :no, :default => false
  end

  def self.down
    remove_column :events, :receive_comment_notification
  end
end
