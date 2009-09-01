class Picture < ActiveRecord::Base

  sortable :scope => [:parent_id, :parent_type, :state]

  has_attached_file :attached, :styles => {
    #:original => "1024x768>",
    :large => "504x504>",  #has to be multiple of 18
    :medium => "252x252>",
    :small => "126x126>",
    :thumb => "72x72>"}

  validates_attachment_presence :attached
  validates_attachment_content_type :attached, :content_type => 'image/jpeg'

  #validates_presence_of :parent_id
  #validates_presence_of :parent_type
  validates_presence_of :creator_id

  acts_as_commentable

  acts_as_rateable

  include AASM
  aasm_column :state
  aasm_initial_state :initial => :passive
  aasm_state :passive
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended, :enter => :do_suspend
  aasm_state :archive,  :enter => :do_activate


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
    set_activated
    self.activated_at = Time.now.utc
  end

  def set_activated
    @activated = true
  end
  

  def self.find_parent(parent_str, parent_id)
    parent_str.constantize.find(parent_id)
  end

  def get_parent_object
    parent_type.constantize.find(parent_id)
  end

  def is_user_moderator?(user)
    get_parent_object.is_user_moderator?(user)
  end

  def get_moderators_list
    get_parent_object.get_moderators_list
  end

end
