class CategoriesEvents < ActiveRecord::Migration
  def self.up
    create_table("categories_events", :id=>false) do |t|
      t.integer :category_id
      t.integer :event_id
    end
  end

  def self.down
    drop_table "categories_events"
  end
end
