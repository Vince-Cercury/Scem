class AddEventState < ActiveRecord::Migration
  def self.up
    add_column :events, :state, :string, :null => :no, :default => "passive"
    add_column :events, :canceled_at, :datetime
    add_column :events, :activated_at, :datetime
  end

  def self.down
    remove_column :events, :state
    remove_column :events, :canceled_at
    remove_column :events, :activated_at
  end
end
