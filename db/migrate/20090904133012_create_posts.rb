class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :name
      t.text :text_short
      t.text :text_long
      t.integer :creator_id
      t.string :state, :null => :no, :default => "passive"
      t.integer :parent_id
      t.string :parent_type
      t.integer :activated_by
      t.datetime :activated_at
      t.integer :suspended_by
      t.datetime :suspended_at
      t.integer :edited_by
      t.datetime :edited_at

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
