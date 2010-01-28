class AddPositions < ActiveRecord::Migration
  def self.up
    rename_column :pictures, :position, :position_active
    add_column :pictures, :position_unactive, :integer
  end

  def self.down
    rename_column :pictures, :position_active, :position
    remove_column :pictures, :position_unactive
  end
end
