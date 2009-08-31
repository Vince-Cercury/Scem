class AddPictureState < ActiveRecord::Migration
  def self.up
    add_column    :pictures, :state, :string, :null => :no, :default => "passive"
    add_column    :pictures, :suspended_at, :datetime
    add_column    :pictures, :suspended_by, :integer
    add_column    :pictures, :activated_by, :datetime
    add_column    :pictures, :activated_at, :integer
  end

  def self.down
    remove_column    :pictures, :state
    remove_column    :pictures, :suspended_at
    remove_column    :pictures, :suspended_by
    remove_column    :pictures, :activated_by
    remove_column    :pictures, :activated_at
  end
end
