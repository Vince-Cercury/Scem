class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true

  validates_presence_of :text
  validates_length_of :text, :maximum=>1000
  validates_length_of :text, :minimum=>2

  
  # NOTE: install the acts_as_votable plugin if you 
  # want user to vote on the quality of comments.
  #acts_as_voteable
  
  # NOTE: Comments belong to a user
  belongs_to :user

  include AASM
  aasm_column :state
  aasm_initial_state :initial => :passive
  aasm_state :passive
  aasm_state :active,  :enter => :do_activate
  aasm_state :edited, :enter => :do_edit
  aasm_state :suspended, :enter => :do_suspend

  aasm_event :activate do
    transitions :from => :passive, :to => :active
  end

  aasm_event :edit do
    transitions :from => [:passive, :active, :edited], :to => :edited
  end

  aasm_event :suspend do
    transitions :from => [:passive, :active, :edited], :to => :suspended
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active
    transitions :from => :suspended, :to => :edited, :guard => Proc.new {|c| !c.edited_at.blank? }
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

  def do_edit
    self.edited_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
  end
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ? and state = ?", commentable_str, commentable_id, "active"],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def get_parent_object
    commentable_type.constantize.find(commentable_id)
  end

end