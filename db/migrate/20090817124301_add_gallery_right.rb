class AddGalleryRight < ActiveRecord::Migration
  def self.up
    add_column  :galleries, :add_picture_right, :string, :null => :no, :default => "moderators"
    add_column  :galleries, :add_picture_moderation, :boolean, :null => :no, :default => true
  end

  def self.down
    remove_column  :galleries, :add_picture_right
    remove_column  :galleries, :add_picture_moderation
  end
end
