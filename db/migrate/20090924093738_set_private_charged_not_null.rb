class SetPrivateChargedNotNull < ActiveRecord::Migration
  def self.up
    change_column :events, :is_private, :boolean, :null => :no, :default => false
    change_column :events, :is_charged, :boolean, :null => :no, :default => false
  end

  def self.down
    change_column :events, :is_private, :boolean, :null => :yes
    change_column :events, :is_charged, :boolean, :null => :yes
  end
end
