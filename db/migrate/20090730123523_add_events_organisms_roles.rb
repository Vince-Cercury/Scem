class AddEventsOrganismsRoles < ActiveRecord::Migration
  def self.up
    rename_table :events_organisms, :contributions
    add_column :contributions, :role, :string
  end

  def self.down
    rename_table :contributions, :events_organisms
    remove_column :events_organisms, :role
  end
end
