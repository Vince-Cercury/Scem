class AddMemberPasswordOrganism < ActiveRecord::Migration
  def self.up
    add_column  :organisms, :members_password, :string
  end

  def self.down
    remove_column  :organisms, :members_password
  end
end
