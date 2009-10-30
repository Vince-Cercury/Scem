class AddEventAddress < ActiveRecord::Migration
  def self.up
    add_column  :organisms, :location, :string
    add_column  :organisms, :street, :string
    add_column  :organisms, :city, :string
  end

  def self.down
    add_column  :organisms, :street, :string
    remove_column  :organisms, :street
    remove_column  :organisms, :city
  end
end
