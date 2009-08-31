class AlterOrganism < ActiveRecord::Migration
  def self.up
    remove_column :organisms, :is_active
    #following line, limit not working
    change_column :organisms, :description_short, :string, :limit => 500
    change_column :organisms, :in_directory, :boolean, :default => true
  end

  def self.down
    add_column :organisms, :is_active, :boolean
    change_column :organisms, :description_short, :text
    change_column :organisms, :in_directory, :boolean
  end
end
