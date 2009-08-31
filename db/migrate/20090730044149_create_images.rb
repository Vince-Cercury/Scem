class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :url_prefix
      t.string :big_url
      t.string :normal_url
      t.string :small_url
      t.string :thumb_url

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
