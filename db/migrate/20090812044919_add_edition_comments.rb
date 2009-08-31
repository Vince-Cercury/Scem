class AddEditionComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :edited_by, :integer
    add_column :comments, :edited_at, :datetime
    add_column :comments, :state, :string, :null => :no, :default => "passive"
    add_column :comments, :suspended_at, :datetime
    add_column :comments, :suspended_by, :integer
    add_column :comments, :activated_by, :integer
    add_column :comments, :activated_at, :datetime
  end

  def self.down
    remove_column :comments, :edited_by
    remove_column :comments, :edited_at
    remove_column :comments, :state
    remove_column :comments, :suspended_at
    remove_column :comments, :suspended_by
    remove_column :comments, :activated_at
    remove_column :comments, :activated_by
  end
end
