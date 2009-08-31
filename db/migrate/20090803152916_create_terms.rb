class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms  do |t|
      t.datetime :start
      t.datetime :end
      t.integer :event_id

      t.timestamps
    end
    add_index :terms, :event_id
  end

  def self.down
    drop_table :terms
  end
end
