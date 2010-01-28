class AddColumnRank < ActiveRecord::Migration
  def self.up
    add_column :terms, :rank, :integer, :default => 5
  end

  def self.down
    add_column :terms, :rank
  end
end
