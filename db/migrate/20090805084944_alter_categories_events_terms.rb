class AlterCategoriesEventsTerms < ActiveRecord::Migration
  #reorganize the associations between categories, events and terms
  #create a ternaire association table called :categories_dates_events
  #create a specific table for terms
  #big use of has_many through.
  #will allow doing event.categories
  #                 event.terms
  # but getting uniq results witgh the constraints uniq=>true
  #To resume, we have then 3 tables:
  #categories, events, terms
  #linked together thanks to :categories_dates_events

  def self.up
    drop_table :terms

    create_table :terms  do |t|
      t.datetime :start
      t.datetime :end

      t.timestamps
    end

    add_column :terms, :event_id, :integer

    create_table :categories_events, :id=>false  do |t|
      t.integer :category_id
      t.integer :event_id

      t.timestamps
    end
    add_index :categories_events, :category_id
    add_index :categories_events, :event_id
    
  end

  def self.down
    drop_table :terms
    create_table :terms  do |t|
      t.datetime :start
      t.datetime :end
      t.integer :event_id

      t.timestamps
    end
    add_index :terms, :event_id
    add_column :terms, :category_id, :integer
    add_index :terms, :category_id
    drop_table :categories_terms
    drop_table :categories_events
  end
end
