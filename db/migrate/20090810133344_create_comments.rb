class CreateComments < ActiveRecord::Migration
def self.up
    create_table :comments, :force => true do |t|
      t.text :text, :default => ""
      t.timestamps
      t.integer :user_id, :default => 0, :null => false
      t.references :commentable, :polymorphic => true
    end
    add_index :comments, ["user_id"], :name => "fk_comments_user"
  end


  def self.down
    drop_table :comments
  end
end
