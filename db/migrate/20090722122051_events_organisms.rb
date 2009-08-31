class EventsOrganisms < ActiveRecord::Migration
  def self.up
    create_table("events_organisms", :id=>false) do |t|
      t.integer :event_id
      t.integer :organism_id
    end
  end

  def self.down
    drop_table "events_organisms"
  end
end
