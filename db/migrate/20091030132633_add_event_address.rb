class AddEventAddress < ActiveRecord::Migration
  def self.up
    add_column  :events, :location, :string
    add_column  :events, :street, :string
    add_column  :events, :city, :string
  end

  def self.down
    remove_column  :organisms, :location
    remove_column  :events, :street
    remove_column  :events, :city
  end
end
