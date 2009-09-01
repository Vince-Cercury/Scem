class Event < ActiveRecord::Base

  has_many :galleries, :as => :parent, :dependent => :destroy

  has_one :picture, :as => :parent, :dependent => :destroy, :conditions => "pictures.state = 'active'"

  acts_as_commentable

  acts_as_rateable

  validates_presence_of :name, :description_short
  
  has_many :terms
  has_and_belongs_to_many :categories


  has_many :contributions
  has_many :organisms, :through => :contributions, :uniq => true

  with_options :through => :contributions, :source => :organism do |obj|
    obj.has_many :publishers, :conditions => "contributions.role = 'publisher'"
    obj.has_many :organizers, :conditions => "contributions.role = 'organizer'"
    obj.has_many :partners, :conditions => "contributions.role = 'partner'"
  end

  
  def self.search(search, page)
    paginate :per_page => ENV['PER_PAGE'], :page => page,
      :conditions => ['name like ?', "%#{search}%"],
      :order => 'name'
  end


  # in the future we can change the select to have many publisher per event
  #but now we want to restrict to just one
  def get_first_publisher
    self.publishers.all.first.id unless self.publishers.all.first.nil?
  end

  def is_granted_to_edit?(user)
    result = false

    if(user.has_system_role("moderator"))
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


  def is_user_moderator?(user)
    result = false


    self.publishers.each do |organism|
      if organism.is_user_moderator?(user)
        result = true
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
      list += term.sure_participants
    end
    return list
  end

  def get_parent_object
    nil
  end

end

