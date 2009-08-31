class AddUserReceivePictureNotification < ActiveRecord::Migration
  def self.up
    add_column  :users, :receive_picture_notification, :boolean, :null => :no, :default => true
  end

  def self.down
    remove_column  :users, :receive_picture_notification
  end
end
