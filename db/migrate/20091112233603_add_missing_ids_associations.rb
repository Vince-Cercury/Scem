class AddMissingIdsAssociations < ActiveRecord::Migration
  def self.up
    add_column :contributions, :id, :primary_key
    #add_column :participations, :id, :primary_key
  end

  def self.down
    remove_column :contributions, :id, :primary_key
    #remove_column :participations, :id, :primary_key
  end
end
