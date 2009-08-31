class ActivitiesOrganisms < ActiveRecord::Migration
  def self.up
    create_table("activities_organisms", :id=>false) do |t|
      t.integer :activity_id
      t.integer :organism_id
    end
  end

  def self.down
    drop_table "activities_organisms"
  end
end
