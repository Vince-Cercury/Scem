class AddFacebookEidToTerms < ActiveRecord::Migration
  def self.up
    add_column :terms, :facebook_eid, :integer
    #if mysql
    execute("alter table terms modify facebook_eid bigint")
  end

  def self.down
    remove_column :terms, :facebook_eid
  end
end
