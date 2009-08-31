class CreateOrganisms < ActiveRecord::Migration
  def self.up
    create_table :organisms do |t|
      t.string :name
      t.text :description_short
      t.text :description_long
      t.string :manager_name
      t.string :phone
      t.boolean :is_active
      t.boolean :in_directory

      t.timestamps
    end
  end

  def self.down
    drop_table :organisms
  end
end
