class CreateParticipation < ActiveRecord::Migration
  def self.up
    create_table("participations") do |t|
      t.integer :term_id
      t.integer :user_id
      t.string  :role
      t.timestamps
    end
    add_index :participations, :term_id
    add_index :participations, :user_id
  end

  def self.down
    drop_table "participations"
  end
end
