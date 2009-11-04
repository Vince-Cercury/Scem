require 'digest/sha1'

class User < ActiveRecord::Base

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  serialize   :facebook_friends_info, Array

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :first_name,     :maximum => 100
  validates_presence_of     :first_name

  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100
  validates_presence_of     :last_name

  validates_presence_of     :email, :if =>  :validate_email?
  validates_length_of       :email,    :within => 6..100, :if =>  :validate_email? #r@a.wk
  validates_uniqueness_of   :email, :if =>  :validate_email?
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message, :if =>  :validate_email?


  def set_validate_password(value)
    @validate_password = value
  end

  def validate_password?
    return @validate_password unless @validate_password.nil?
    return true
  end

    def set_validate_email(value)
    @validate_email = value
  end

  def validate_email?
    return @validate_email unless @validate_email.nil?
    return true
  end

  #validates_date :date_of_birth,
  #  :before => Proc.new { 3.years.ago },
  #  :before_message => ": must be at least 3 years old",
  #  :after => Proc.new { 130.years.ago },
  #  :after_message => ": too old, 130 is the max",
  #  :allow_nil => false

  has_many :posts, :as => :parent, :dependent => :destroy

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

  has_many :organisms_users
  has_many :organisms, :through => :organisms_users
  with_options :through => :organisms_users, :source => :organism do |obj|
    obj.has_many :is_member_of, :conditions => "organisms_users.role = 'member' and organisms_users.state='active' and organisms.state='active'"
    obj.has_many :is_moderator_of, :conditions => "organisms_users.role = 'moderator' and organisms_users.state='active' and organisms.state='active'"
    obj.has_many :is_admin_or_moderator_of, :conditions => "(organisms_users.role = 'moderator' or organisms_users.role = 'admin') and organisms_users.state='active' and organisms.state='active'"
    obj.has_many :is_admin_of, :conditions => "organisms_users.role = 'admin' and organisms_users.state='active' and organisms.state='active'"

    obj.has_many :is_member_of_pending, :conditions => "organisms_users.role = 'member' and organisms_users.state='pending"
    obj.has_many :is_moderator_of_pending, :conditions => "organisms_users.role = 'moderator' and organisms_users.state='pending"
    obj.has_many :is_admin_of_pending, :conditions => "organisms_users.role = 'admin' and organisms_users.state='pending"
  end
  
  has_many :participations
  has_many :participate, :through => :participations

  with_options :through => :participations, :source => :term do |obj|
    obj.has_many :sure_participate, :conditions => "participations.role = 'sure'"
    obj.has_many :maybe_participate, :conditions => "participations.role = 'maybe'"
    obj.has_many :not_participate, :conditions => "participations.role = 'not'"
  end

  after_create :register_user_to_fb
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation, :image, :receive_comment_notification, :receive_picture_notification, :date_of_birth

  #search method for user
  def self.search(search, page)
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['(login like ? or first_name like ? or last_name like ?) and state=?', "%#{search}%","%#{search}%","%#{search}%",'active'],
      :order => 'login, first_name, last_name'
  end

  def search_participate(role, search, page)
    case role
    when "maybe"
      maybe_participate.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ?', "%#{search}%"],
        :include => :event,
        :order => 'events.name'
    when "not"
      not_participate.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ?', "%#{search}%"],
        :include => :event,
        :order => 'events.name'
    else
      sure_participate.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ?', "%#{search}%"],
        :include => :event,
        :order => 'events.name'
    end
  end

  def search_participate_in_futur(search, page, max_results)
    participations.paginate :per_page => max_results, :page => page,
        :conditions => ["name like ? and (role='maybe' or role='sure') ", "%#{search}%"],
        #:include => :event,
        :joins => "inner join terms on terms.id = participations.term_id inner join events on events.id = terms.event_id ",
        :order => 'start_at ASC'
  end

  def search_organisms(role, search, page)
    
    if role=="admin"
      is_admin_of.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['organisms.name like ? and organisms.state = ?', "%#{search}%", "active"],
        :order => 'name'
    elsif role=="moderator"
      is_moderator_of.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['organisms.name like ? and organisms.state=?', "%#{search}%", "active"],
        :order => 'name'
    else
      is_member_of.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['organisms.name like ? and organisms.state=?', "%#{search}%", "active"],
        :order => 'name'
    end

  end

  def search_organisms_pending(role, search, page)

    if role=="admin"
      is_admin_of_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ? and state = ?', "%#{search}%", "active"],
        :order => 'name'
    elsif role=="moderator"
      is_moderator_of_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ? and state=?', "%#{search}%", "active"],
        :order => 'name'
    else
      is_member_of_pending.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['name like ? and state=?', "%#{search}%", "active"],
        :order => 'name'
    end

  end

  def get_moderators_list
    moderators_list = Array.new
    moderators_list +=self
  end

  #Huuuu ?? wtf ? will never work, where does the variable id comes from ?
  def is_user_moderator?(user)
    if user
      if id==user.id
        return true
      end
    end
    return false
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #find the user in the database, first by the facebook user id and if that fails through the email hash
  def self.find_by_fb_user(fb_user)
    User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
  end
  #Take the data returned from facebook and create a new user from it.
  #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def self.create_from_fb_connect(fb_user)
    new_facebooker = User.new(:first_name => fb_user.first_name, :last_name => fb_user.last_name, :login => "facebooker_#{fb_user.uid}", :password => "", :email => "", :state => "active")
    new_facebooker.fb_user_id = fb_user.uid.to_i
    new_facebooker.email = fb_user.proxied_email
    #We need to save without validations
    new_facebooker.save(false)
    #Following line does not look correct
    #new_facebooker.register_user_to_fb
  end

  #We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id)
    unless fb_user_id.nil?
      #check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
      #link the new one
      self.fb_user_id = fb_user_id
      save(false)
    end
  end

  #The Facebook registers user method is going to send the users email hash and our account id to Facebook
  #We need this so Facebook can find friends on our local application even if they have not connect through connect
  #We hen use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end

  # Check User for System role with passed 'role'
  #
  # Usage:
  #
  # <tt>user.has_system_role('admin')</tt>
  #
  # will return true if the user has role 'admin' or if he is superadmin
  #
	def has_system_role(role_name)
		return (self.role == role_name) || (self.role == 'admin')
	end

  def self.facebook_user_accepted_this_app?(facebook_uid)
    if find_by_fb_user_id(:first,facebook_uid)
      true
    else
      false
    end
  end

  def get_picture_root_path
    return 'users/'+id.to_s
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end


end
