class AddGalleryName < ActiveRecord::Migration
  def self.up
    add_column  :galleries, :name, :string
  end

  def self.down
    remove_column  :galleries, :name, :string
  end
end
