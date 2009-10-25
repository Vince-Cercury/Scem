class CreateMailing < ActiveRecord::Migration
  def self.up
    create_table :mails do |t|
      t.integer :sender_id
      t.string  :subject
      t.text    :body

      t.timestamps
    end
    add_index :mails, :sender_id

    create_table("recipients") do |t|
      t.integer :user_id
      t.integer :mail_id
      t.boolean :sent, :null => :no, :default => false
    end
  end

  def self.down
    drop_table :mails
    drop_table :recipients
  end
end
