class Organism < ActiveRecord::Base
  include SharedMethods
  before_validation :remove_whitespace_from_name

  attr_accessible :name, :activity_ids, :description_short, :description_long, :manager_name, :phone, :street, :city


  has_friendly_id :name, :use_slug => true, :strip_diacritics => true #, :reserved => ["new","edit"]

  before_save :generate_and_save_passwords


  validates_acceptance_of :terms_of_service#, :allow_nil =>false
  validates_presence_of     :name, :description_short, :manager_name, :phone
  validates_uniqueness_of   :name
  validates_length_of :description_short, :maximum=>400

  has_many :galleries, :as => :parent, :dependent => :destroy

  has_many :posts, :as => :parent, :dependent => :destroy

  has_one :picture, :as => :parent, :dependent => :destroy, :conditions => "pictures.state = 'active'"

  acts_as_commentable

  acts_as_rateable



  include AASM
  aasm_column :state

  aasm_initial_state :initial => :pending
  
  aasm_state :passive
  aasm_state :pending, :enter => :make_activation_code
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete
  

  has_many :contributions
  has_many :events, :through => :contributions

  has_many :organisms_users
  has_many :users, :through => :organisms_users
  with_options :through => :organisms_users, :source => :user do |obj|
    obj.has_many :members, :conditions => "organisms_users.role = 'member' and organisms_users.state='active'"
    obj.has_many :moderators, :conditions => "organisms_users.role = 'moderator' and organisms_users.state='active'"
    obj.has_many :admins, :conditions => "organisms_users.role = 'admin' and organisms_users.state='active'"


    obj.has_many :members_pending, :conditions => "organisms_users.role = 'member' and organisms_users.state='pending'"
    obj.has_many :moderators_pending, :conditions => "organisms_users.role = 'moderator' and organisms_users.state='pending'"
    obj.has_many :admins_pending, :conditions => "organisms_users.role = 'admin' and organisms_users.state='pending'"
  end

  has_and_belongs_to_many :activities

  def generate_and_save_passwords
    (self.admins_password = ActiveSupport::SecureRandom.base64(6)) unless self.admins_password
    (self.moderators_password = ActiveSupport::SecureRandom.base64(6)) unless self.moderators_password
  end

  def self.search(search, page, in_directory=true, event_state='active')
    conditions = SearchsTools.prepare_conditions(search, 'organisms.name', 'organisms.in_directory = ? and organisms.state = ?', [in_directory, event_state])
    
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => conditions,
      :order => 'name'
  end

  def self.count_search(search, in_directory=true, event_state='active')
    conditions = SearchsTools.prepare_conditions(search, 'organisms.name', 'organisms.in_directory = ? and organisms.state = ?', [in_directory, event_state])

    count 'organisms.id',
      :conditions => conditions,
      :distinct => true
  end

  def get_last_organism_users(number)
    organisms_users.all(:order => 'id DESC', :limit =>number)
  end

  def search_users_by_role(role, search, page)
    if role=="admins"
      admins.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login, first_name, last_name'
    elsif role=="moderators"
      moderators.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login, first_name, last_name'
    else
      members.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login'
    end
  end

  def search_users(search, page)

      users.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login, first_name, last_name'

  end

  def search_users_pending(role, search, page)
    if role=="admins"
      admins_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ? and state=?', "%#{search}%","%#{search}%","%#{search}%",:active],
        :order => 'login, first_name, last_name'
    elsif role=="moderators"
      moderators_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ? and state=?', "%#{search}%","%#{search}%","%#{search}%",:active],
        :order => 'login, first_name, last_name'
    else
      members_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ? and state=?', "%#{search}%","%#{search}%","%#{search}%",:active],
        :order => 'login'
    end

  end

  def search_galleries(search, page, state = 'active')
    galleries.paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ? and state = ?', "%#{search}%", state],
      :order => 'name'
  end

  def search_events(search, page)
    events.paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ?', "%#{search}%"],
      :order => 'name'
  end

  def search_posts(search, page)
    posts.paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ?',"%#{search}%"],
      :order => 'created_at DESC'
  end

  def search_posts_by_state(search, page, state)
    posts.paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ? and state=?', "%#{search}%", state],
      :order => 'created_at DESC'
  end

  aasm_event :register do
    transitions :from => :passive, :to => :pending , :guard => Proc.new {|g| !g.manager_name.blank? and !g.description_short.blank? }
  end

  aasm_event :activate do
    transitions :from => :pending, :to => :active
  end

  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end

  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active, :guard => Proc.new {|g| !g.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|g| !g.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  def recently_activated?
    @activated
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end


  def make_activation_code
    self.deleted_at = nil
    self.activation_code = make_token
  end

  # Moderator
  #
  # will return true if the logged in user has organism role of Moderator('admin') or Administrator('admin')
  # or system moderator or system admin
  #	def ensure_user_moderator?(user)
  #    no_permission_redirection unless is_user_moderator?(user)
  #	end

  def is_user_moderator?(user)
    if user
      user && (self.moderators.include?(user) or self.admins.include?(user)) or user.has_system_role('moderator')
    else
      return false
    end
	end

  def is_user_member?(user)
    user && (self.members.include?(user) or self.moderators.include?(user) or self.admins.include?(user)) or user.has_system_role('moderator')
	end

  def is_user_admin?(user)
    user && (self.admins.include?(user)) or user.has_system_role('moderator')
	end

  def is_user_related?(user)
    user && (self.members.include?(user) or self.moderators.include?(user) or self.admins.include?(user))
	end

  def is_user_pending?(user)
    user && (self.members_pending.include?(user) or self.moderators_pending.include?(user) or self.admins_pending.include?(user))
	end

  def get_moderators_list
    admins + moderators
  end

  #very very bad method
  def get_parent_object
    nil
  end

  def get_picture_root_path
    return 'organisms/'+id.to_s
  end

  protected

  #TODO: put make_token and secure_digest into a library
  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end



end
