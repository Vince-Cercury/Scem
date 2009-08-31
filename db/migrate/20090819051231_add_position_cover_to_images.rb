class AddPositionCoverToImages < ActiveRecord::Migration
  def self.up
    rename_column :pictures, :order, :position
    add_column  :pictures, :cover, :boolean, :null => :no, :default => false
  end

  def self.down
    rename_column :pictures, :position, :order
    remove_column :pictures, :cover
  end
end
