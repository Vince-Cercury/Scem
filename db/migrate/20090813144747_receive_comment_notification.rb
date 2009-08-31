class ReceiveCommentNotification < ActiveRecord::Migration
  def self.up
    remove_column :events, :receive_comment_notification
    add_column    :users, :receive_comment_notification, :boolean, :null => :no, :default => true
  end

  def self.down
    add_column    :events, :receive_comment_notification, :boolean, :null => :no, :default => false
    remove_column :users, :receive_comment_notification
  end
end
