class CategoriesTerms < ActiveRecord::Migration
  def self.up
    drop_table :categories_events
    add_column :terms, :category_id, :integer
    add_index :terms, :category_id
  end

  def self.down
    create_table("categories_events", :id=>false) do |t|
      t.integer :category_id
      t.integer :event_id
    end
    remove_column :terms, :category_id
  end
end
