class AddStateAttributes < ActiveRecord::Migration
  def self.up
    add_column :organisms, :activation_code, :string,  :limit => 40
    add_column :organisms, :activated_at, :datetime
    add_column :organisms, :deleted_at, :datetime
  end

  def self.down
    remove_column :organisms, :activation_code
    remove_column :organisms, :activated_at
    remove_column :organisms, :deleted_at
  end
end
