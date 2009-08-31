class AddUsersFacebookImage < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_image_big, :string
    add_column :users, :fb_image, :string
    add_column :users, :fb_image_small, :string
  end

  def self.down
    remove_column :users, :fb_image
    remove_column :users, :fb_image_big
    remove_column :users, :fb_image_small
  end
end
