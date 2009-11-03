class RenameTermFields < ActiveRecord::Migration
  def self.up
     rename_column  :terms, :start, :start_at
     rename_column  :terms, :end, :end_at
  end

  def self.down
     rename_column  :terms, :start_at, :start
     rename_column  :terms, :end_at, :end
  end
end
