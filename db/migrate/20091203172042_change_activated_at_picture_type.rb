class ChangeActivatedAtPictureType < ActiveRecord::Migration
  def self.up
    change_column :pictures, :activated_by, :integer
    change_column :pictures, :activated_at, :datetime
  end

  def self.down
    change_column :pictures, :activated_at, :integer
    change_column :pictures, :activated_by, :datetime
  end
end
