class AddOrderToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :order, :integer, :null => :no, :default => 1
  end

  def self.down
    remove_column :pictures, :order
  end
end
