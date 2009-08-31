class AddStatusToOrganisms < ActiveRecord::Migration
  def self.up
    add_column :organisms, :state, :string, :null => :no, :default => "passive"
  end

  def self.down
    remove_column :organisms, :state
  end
end
