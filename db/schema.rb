# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091025154241) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities_organisms", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "organism_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "to_display"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_events", :id => false, :force => true do |t|
    t.integer  "category_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_events", ["category_id"], :name => "index_categories_events_on_category_id"
  add_index "categories_events", ["event_id"], :name => "index_categories_events_on_event_id"

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",          :default => 0,         :null => false
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "edited_by"
    t.datetime "edited_at"
    t.string   "state",            :default => "passive"
    t.datetime "suspended_at"
    t.integer  "suspended_by"
    t.integer  "activated_by"
    t.datetime "activated_at"
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "contributions", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "organism_id"
    t.string  "role"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description_short"
    t.text     "description_long"
    t.boolean  "is_charged",        :default => false, :null => false
    t.boolean  "is_private",        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "edited_by"
  end

  create_table "galleries", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.string   "description"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "add_picture_right",      :default => "moderators"
    t.boolean  "add_picture_moderation", :default => true
    t.string   "name"
  end

  create_table "images", :force => true do |t|
    t.string   "url_prefix"
    t.string   "big_url"
    t.string   "normal_url"
    t.string   "small_url"
    t.string   "thumb_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mails", :force => true do |t|
    t.integer  "sender_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mails", ["sender_id"], :name => "index_mails_on_sender_id"

  create_table "organisms", :force => true do |t|
    t.string   "name"
    t.string   "description_short", :limit => 500
    t.text     "description_long"
    t.string   "manager_name"
    t.string   "phone"
    t.boolean  "in_directory",                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code",   :limit => 40
    t.datetime "deleted_at"
    t.datetime "activated_at"
    t.string   "state",                            :default => "passive"
    t.string   "members_password"
    t.integer  "created_by"
    t.integer  "edited_by"
  end

  create_table "organisms_users", :force => true do |t|
    t.integer  "organism_id"
    t.integer  "user_id"
    t.string   "role"
    t.string   "state",           :default => "passive"
    t.string   "password_member"
    t.datetime "activated_at"
  end

  add_index "organisms_users", ["organism_id"], :name => "index_organisms_users_on_organism_id"
  add_index "organisms_users", ["user_id"], :name => "index_organisms_users_on_user_id"

  create_table "participations", :force => true do |t|
    t.integer  "term_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participations", ["term_id"], :name => "index_participations_on_term_id"
  add_index "participations", ["user_id"], :name => "index_participations_on_user_id"

  create_table "pictures", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.string   "description"
    t.integer  "creator_id"
    t.string   "attached_file_name"
    t.string   "attached_content_type"
    t.integer  "attached_file_size"
    t.datetime "attached_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                 :default => "passive"
    t.datetime "suspended_at"
    t.integer  "suspended_by"
    t.datetime "activated_by"
    t.integer  "activated_at"
    t.integer  "position",              :default => 1
    t.boolean  "cover",                 :default => false
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.text     "text_short"
    t.text     "text_long"
    t.integer  "creator_id"
    t.string   "state",        :default => "passive"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "activated_by"
    t.datetime "activated_at"
    t.integer  "suspended_by"
    t.datetime "suspended_at"
    t.integer  "edited_by"
    t.datetime "edited_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0
    t.datetime "created_at",                                  :null => false
    t.string   "rateable_type", :limit => 15, :default => "", :null => false
    t.integer  "rateable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"

  create_table "recipients", :force => true do |t|
    t.integer "user_id"
    t.integer "mail_id"
    t.boolean "sent",    :default => false
  end

  create_table "terms", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "facebook_eid", :limit => 8
  end

  create_table "users", :force => true do |t|
    t.string   "login",                        :limit => 40
    t.string   "email",                        :limit => 100
    t.string   "crypted_password",             :limit => 40
    t.string   "salt",                         :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",               :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",              :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                       :default => "passive"
    t.datetime "deleted_at"
    t.string   "first_name",                   :limit => 100
    t.string   "last_name",                    :limit => 100
    t.datetime "date_of_birth"
    t.integer  "fb_user_id",                   :limit => 8
    t.string   "email_hash"
    t.string   "role"
    t.string   "fb_image_big"
    t.string   "fb_image"
    t.string   "fb_image_small"
    t.boolean  "receive_comment_notification",                :default => true
    t.boolean  "receive_picture_notification",                :default => true
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
