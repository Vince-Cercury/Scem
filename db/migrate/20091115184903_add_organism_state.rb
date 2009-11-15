class AddOrganismState < ActiveRecord::Migration
  def self.up
    add_column :galleries, :state, :string, :null => :no, :default => "passive"
    add_column :galleries, :activated_at, :datetime
    add_column :galleries, :suspended_at, :datetime
    execute("UPDATE galleries set state = 'active'")
  end

  def self.down
    remove_column :galleries, :state
    remove_column :galleries, :activated_at
    remove_column :galleries, :suspended_at
  end
end
