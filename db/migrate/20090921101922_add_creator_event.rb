class AddCreatorEvent < ActiveRecord::Migration
  def self.up
    add_column  :events, :created_by, :integer
    add_column  :events, :edited_by, :integer
  end

  def self.down
    remove_column  :events, :created_by
    remove_column  :events, :edited_by
  end
end
