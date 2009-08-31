class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :parent_id
      t.string :parent_type
      t.string :description
      t.integer :creator_id

      t.timestamps
    end
  end

  def self.down
    drop_table :galleries
  end
end
