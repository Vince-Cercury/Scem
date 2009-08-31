class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.integer :parent_id
      t.string :parent_type
      t.string :description
      t.integer :creator_id
      t.string :attached_file_name
      t.string :attached_content_type
      t.integer :attached_file_size
      t.datetime :attached_updated_at


      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
