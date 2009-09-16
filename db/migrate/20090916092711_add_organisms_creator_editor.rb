class AddOrganismsCreatorEditor < ActiveRecord::Migration
  def self.up
    add_column  :organisms, :created_by, :integer
    add_column  :organisms, :edited_by, :integer
  end

  def self.down
    remove_column :organisms, :created_by
    remove_column :organisms, :edited_by
  end
end
