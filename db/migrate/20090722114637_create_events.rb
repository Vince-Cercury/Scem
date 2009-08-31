class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.text :description_short
      t.text :description_long
      t.boolean :is_charged
      t.boolean :is_private

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
