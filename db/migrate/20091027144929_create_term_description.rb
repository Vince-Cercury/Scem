class CreateTermDescription < ActiveRecord::Migration
  def self.up
    add_column :terms, :description, :text
  end

  def self.down
    remove_column :terms, :description
  end
end
