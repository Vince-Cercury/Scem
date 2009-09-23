class Post < ActiveRecord::Base

  belongs_to :parent, :polymorphic => true

  acts_as_commentable

  validates_presence_of :name, :text_short

  #validates_presence_of :parent_id
  validates_presence_of :parent_type
  validates_presence_of :creator_id

  def self.find_parent(parent_type, parent_id)
    parent_type.constantize.find(parent_id)
  end

  def get_parent_object
    parent_type.constantize.find(parent_id)
  end

  def get_picture_root_path
    get_parent_object.get_picture_root_path + '/blog_posts/'+id.to_s
  end

  def is_user_moderator?(user)
    if user
      get_parent_object.is_user_moderator?(user)
    else
      return false
    end
  end

  def get_moderators_list
    get_parent_object.get_moderators_list
  end

   acts_as_rateable

  include AASM
  aasm_column :state
  aasm_initial_state :initial => :passive
  aasm_state :passive
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended, :enter => :do_suspend


  aasm_event :activate do
    transitions :from => :passive, :to => :active
  end

  aasm_event :suspend do
    transitions :from => [:passive, :active, :edited], :to => :suspended
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active
    transitions :from => :suspended, :to => :passive
  end

  def recently_activated?
    @activated
  end

  def recently_suspended?
    @suspended
  end

  def do_suspend
    @suspended = true
    self.suspended_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
  end

  
end
