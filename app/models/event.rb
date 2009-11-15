class Event < ActiveRecord::Base
  include SharedMethods
  before_validation :remove_whitespace_from_name

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true #, :reserved => ["new","edit"]

  has_many :galleries, :as => :parent, :dependent => :destroy

  has_one :picture, :as => :parent, :dependent => :destroy, :conditions => "pictures.state = 'active'"

  has_many :posts, :as => :parent, :dependent => :destroy



  include AASM
  aasm_column :state

  aasm_initial_state :initial => :pending

  aasm_state :passive
  aasm_state :pending
  aasm_state :active,  :enter => :do_activate
  aasm_state :canceled, :enter => :do_cancel

  aasm_event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|e| !e.name.blank? }
  end

  aasm_event :activate do
    transitions :from => :pending, :to => :active, :guard => Proc.new {|e| !e.name.blank? }
    transitions :from => :passive, :to => :active, :guard => Proc.new {|e| !e.name.blank? }
  end

  aasm_event :cancel do
    transitions :from => [:passive, :pending, :active], :to => :canceled
  end

  aasm_event :uncancel do
    transitions :from => :canceled, :to => :active, :guard => Proc.new {|e| !e.manager_name.blank? and !e.description_short.blank? }
    transitions :from => :canceled, :to => :pending, :guard => Proc.new {|e| !e.manager_name.blank? and !e.description_short.blank? }
    transitions :from => :canceled, :to => :passive, :guard => Proc.new {|e| !e.manager_name.blank? and !e.description_short.blank? }
  end

  def recently_activated?
    @activated
  end

  def do_cancel
    self.canceled_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    self.canceled_at  = nil
  end

  def canceled?
    if state=='canceled'
      return true
    end
    return false
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

  acts_as_commentable

  acts_as_rateable

  validates_presence_of :name, :description_short
  validates_length_of :description_short, :maximum=>800

  
  has_many :terms, :dependent => :destroy
  has_and_belongs_to_many :categories#, :conditions => "categories.to_display = true"


  has_many :contributions, :dependent => :destroy
  has_many :organisms, :through => :contributions, :uniq => true

  with_options :through => :contributions, :source => :organism do |obj|
    obj.has_many :publishers, :conditions => "contributions.role = 'publisher'"
    obj.has_many :organizers, :conditions => "contributions.role = 'organizer'"
    obj.has_many :partners, :conditions => "contributions.role = 'partner'"
    obj.has_many :places, :conditions => "contributions.role = 'place'"
  end


  #MANAGE TERMS
  #validates_associated :terms

  after_update :save_terms


  def new_term_attributes=(term_attributes)
    term_attributes.each do |attributes|
      if attributes['description'].blank?
        attributes['description'] = ''
      end
      #raise attributes.inspect
      parsed_attributes = parse_my_date(attributes)
      terms.build(parsed_attributes)
    end
    #raise terms.inspect
  end

  def existing_term_attributes=(term_attributes)
    
    terms.reject(&:new_record?).each do |term|
      attributes = term_attributes[term.to_param]
      if attributes
        term.attributes = parse_my_date(attributes)
      else
        terms.delete(term)
      end
    end
    
  end

  def save_terms
    terms.each do |term|
      term.save(false)
    end
  end

  #MANAGE CONTRIBUTIONS
  validates_associated :contributions
  

  #  before_update :delete_contributions
  #
  #  def delete_contributions
  #    contributions.delete_all
  #  end

  #auto complete organizers proced result
  def existing_organizer_attributes=(organizer_attributes)
    organizer_attributes.each do |attributes|
      proceed_contribution_attribute(attributes[1][:name], 'organizer')
    end
  end

  def new_organizer_attributes=(organizer_attributes)
    organizer_attributes.each do |attributes|
      proceed_contribution_attribute(attributes['name'], 'organizer')
    end
  end

    def existing_partner_attributes=(partner_attributes)
    partner_attributes.each do |attributes|
      proceed_contribution_attribute(attributes[1][:name], 'partner')
    end
  end

  def new_partner_attributes=(partner_attributes)
    partner_attributes.each do |attributes|
      proceed_contribution_attribute(attributes['name'], 'partner')
    end
  end

  def proceed_contribution_attribute(contributor_name, role)
    begin
    contributor = Organism.find_by_name(contributor_name) unless contributor_name.blank?
      if contributor
        if(!self.organizers.include?(contributor))
          contribution = Contribution.new
          #contribution.event_id=self.id
          contribution.organism_id=contributor.id
          contribution.role = role
          self.contributions << contribution
        end
      end
    rescue
      #if record not found, do nothing
    end
  end


  #Auto complete place name proceed result (organism)
  def organism_place_name
    places.first.name if places.first
  end

  def organism_place_name=(name)
    organism_place = Organism.find_by_name(name) unless name.blank?
    if organism_place
      contribution = Contribution.new
      #contribution.event_id=self.id
      contribution.organism_id=organism_place.id
      contribution.role="place"
      self.contributions << contribution
    end
  end

  
  def self.search_has_publisher(search, page, is_private=false)
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :joins => "inner join contributions on contributions.event_id = events.id and contributions.role='publisher'",
      :conditions => ["events.name like ? and events.is_private = ?", "%#{search}%", is_private],
      :order => 'events.name',
      :group => 'events.id'
  end

  def self.search_not_have_publisher(search, page, is_private=false)
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ["events.name like ? and events.is_private = ? and events.id not in (select event_id from contributions where role='publisher' and event_id is not null)", "%#{search}%", is_private],
      :order => 'events.name'
  end

  def self.search(search, page, is_private=false)
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ? and events.is_private = ?', "%#{search}%", is_private],
      :order => 'name'
  end

  def search_galleries(search, page, state = 'active')
    galleries.paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ? and state = ?', "%#{search}%", state],
      :order => 'name'
  end


  # in the future we can change the select to have many publisher per event
  #but now we want to restrict to just one
  def get_first_publisher
    self.publishers.all.first.id unless self.publishers.all.first.nil?
  end

  def get_first_place
    self.places.all.first.id unless self.places.all.first.nil?
  end
  


  def is_granted_to_view?(user)
    result = false

    if(user.has_system_role("moderator"))
      result = true
    end

    if(created_by==user.id)
      result = true
    end

    self.publishers.each do |organism|
      if organism.is_user_member?(user)
        result = true
      end
    end

    self.organizers.each do |organism|
      if organism.is_user_member?(user)
        result = true
      end
    end


    self.partners.each do |organism|
      if organism.is_user_member?(user)
        result = true
      end
    end
   
    return result
  end

  def is_granted_to_edit?(user)
    result = false

    if(user.has_system_role("moderator"))
      result = true
    end

    if(created_by==user.id)
      result = true
    end

    self.publishers.each do |organism|
      if organism.is_user_moderator?(user)
        result = true
      end
    end

    #NOTE:uncomment if you want the organizers allowed to edit event
    #    self.organizers.each do |organism|
    #      if organism.is_user_moderator?(user)
    #        result = true
    #      end
    #    end

    #NOTE:uncomment if you want the partners allowed to edit event
    #    self.partners.each do |organism|
    #      if organism.is_user_moderator?(user)
    #        result = true
    #      end
    #    end

    return result
  end

  def get_moderators_list
    puts "build the moderators list of the event..."
    moderators_list = Array.new
    self.publishers.each do |organism|
      moderators_list +=organism.get_moderators_list
    end
    moderators_list
  end

  #Note: method exactly equal to is_granted_to_edit?, the is something to improve ....
  def is_user_moderator?(user)
    result = false
    if(user)
      if  user.has_system_role('moderator')
        result = true
      end


      if(created_by==user.id)
        result = true
      end

      self.publishers.each do |organism|
        if organism.is_user_moderator?(user)
          result = true
        end
      end
    end
    return result
	
  end

  def is_user_member?(user)
    result = false


    self.publishers.each do |organism|
      if organism.is_user_member?(user)
        result = true
      end
    end
    return result
  end

  def list_participants
    list = Array.new
    terms.each do |term|
      list += term.sure_participants + term.maybe_participants
    end
    return list
  end

  # very very bad method
  def get_parent_object
    nil
  end

  def get_picture_root_path
    return 'events/'+id.to_s
  end

  private
  def parse_my_date(attributes)
    parsed_attributes = Hash.new

    #offset = Time.now.utc_offset.to_s
    #raise Time.zone.inspect
    parsed_attributes[:description] = attributes[:description]
    #raise DateTime.zone.inspect


    end_to_parse = attributes[:end_at] + " "+ attributes[:end_hour] + ":" + attributes[:end_min]# + " "+ Time.zone

    #attributes[:end_at] = Time.parse(end_to_parse)
    #parsed_attributes[:end_at] = Time.parse(end_to_parse)
    begin
      parsed_attributes[:end_at] = DateTime.strptime(end_to_parse,'%d/%m/%Y %H:%M')#.to_time#.to_time.in_time_zone
    rescue
      parsed_attributes[:end_at] =""
    end
    #raise DateTime.strptime(end_to_parse,'%d/%m/%Y %H:%M').to_time.inspect


    start_to_parse = attributes[:start_at] + " "+ attributes[:start_hour] + ":" + attributes[:start_min]# + " "+ Time.zone
    #attributes[:start_at] = Time.parse(start_to_parse)
    #parsed_attributes[:start_at] = Time.parse(start_to_parse)

    begin
      parsed_attributes[:start_at] = DateTime.strptime(start_to_parse,'%d/%m/%Y %H:%M')#.to_time#.to_time.in_time_zone
    rescue
      parsed_attributes[:start_at] = ""
    end
    #raise parsed_attributes.inspect
    #return attributes
    return parsed_attributes
  end
end

