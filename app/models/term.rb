class Term < ActiveRecord::Base

  belongs_to :event

  #has_friendly_id :url_start_param, :use_slug => true, :strip_diacritics => true  #, :scope => :event

  def url_start_param
    s = start_at
    e = end_at
    result = ""
    result += "#{s.day}-#{s.month}-#{s.year}-#{s.hour}-#{s.min}"
    #result += '-to-'
    #result += "#{e.day}-#{e.month}-#{e.year}-#{e.hour}-#{e.min}"
  end

  validates_presence_of :start_at, :end_at
  validates_length_of :description, :maximum=>400

  #validates_datetime :start, :allow_nil => false

  #validates_datetime :end, :allow_nil => false


  validates_datetime :start_at, :after => Proc.new { Time.zone.now },
    :after_message => "date must be in the future"


  validates_datetime :end_at, :after => Proc.new { Time.zone.now },
    :after_message => "date must be in the future"


  validates_datetime :start_at,
    :before => :end_at,
    :before_message => "must be before end"

  def start_hour
    start_at.strftime("%H") unless start_at.nil?
  end

  def start_min
    start_at.strftime("%M") unless start_at.nil?
  end

  def end_hour
    end_at.strftime("%H") unless end_at.nil?
  end

  def end_min
    end_at.strftime("%M") unless end_at.nil?
  end


  has_many :participations
  has_many :participants, :through => :participations

  with_options :through => :participations, :source => :user do |obj|
    obj.has_many :sure_participants, :conditions => "participations.role = 'sure'"
    obj.has_many :maybe_participants, :conditions => "participations.role = 'maybe'"
    obj.has_many :not_participants, :conditions => "participations.role = 'not'"
  end

  def search_participants(role, search, page)
    case role
    when "maybe"
      maybe_participants.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login, first_name, last_name'
    when "not"
      not_participants.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login'
    else
      sure_participants.paginate :per_page => ENV['PER_PAGE'], :page => page,
        :conditions => ['login like ? or first_name like ? or last_name like ?', "%#{search}%","%#{search}%","%#{search}%"],
        :order => 'login, first_name, last_name'
    end
  end

  def self.search_futur(search, page, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ :event],
      :conditions => ['events.name LIKE ? and events.is_private = ? and terms.start_at > NOW()', "%#{search}%", is_private],
      :order => 'start_at ASC'
  end

  def self.search_has_publisher_futur(search, page, per_page, is_private=false)
    paginate  :per_page => per_page,
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ? and terms.start_at > NOW()', "%#{search}%", is_private],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher'",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_no_publisher_futur(search, page, per_page, is_private=false)
    paginate  :per_page => per_page,
      :page => page,
      :include => [ :event],
      :conditions => ["events.name LIKE ? and events.is_private = ? and terms.start_at > NOW() and events.id not in (select event_id from contributions where role='publisher' and event_id is not null)", "%#{search}%", is_private],
      :order => 'start_at ASC'
  end

  def self.search_past(search, page, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ :event],
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at <= NOW() ', "%#{search}%", is_private],
      :order => 'start_at DESC'
  end


  def self.search_has_publisher_past(search, page, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at <= NOW() ', "%#{search}%", is_private],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher'",
      :order => 'start_at DESC',
      :group => 'terms.id'
  end
  

  def self.search_futur_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at >= NOW() and categories.id = ?', "%#{search}%", category_id, is_private],
      :order => 'start_at ASC'
  end

  def self.search_has_publisher_futur_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at >= NOW() and categories_events.category_id = ?', "%#{search}%", is_private, category_id],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_publisher_futur_by_organism(search, page, organism_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at >= NOW() and contributions.organism_id = ?', "%#{search}%", is_private, organism_id],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_publisher_past_by_organism(search, page, organism_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at <= NOW() and contributions.organism_id = ?', "%#{search}%", is_private, organism_id],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_no_publisher_futur_by_category(search, page, per_page, category_id, is_private=false)
    paginate  :per_page => per_page,
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ["events.name LIKE ? and events.is_private = ? and start_at >= NOW() and categories.id = ?  and events.id not in (select event_id from contributions where role='publisher' and event_id is not null)", "%#{search}%", is_private, category_id],
      :order => 'start_at ASC'
  end

  def self.search_past_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and events.is_private = ? and start_at <= NOW() and categories.id = ?', "%#{search}%", is_private, category_id],
      :order => 'start_at DESC'
  end
  
  def self.search_has_publisher_past_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ?  and start_at <= NOW() and categories_events.category_id = ?', "%#{search}%", is_private, category_id],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :order => 'start_at DESC',
      :group => 'terms.id'
  end


  def self.search_ended_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and events.is_private = ? and end_at <= NOW() and categories.id = ?', "%#{search}%", is_private, category_id],
      :order => 'end_at DESC'
  end

  def self.search_has_publisher_ended_by_category(search, page, category_id, is_private=false)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :conditions => ['events.name LIKE ? and events.is_private = ? and end_at <= NOW() and categories_events.category_id = ?', "%#{search}%", is_private, category_id],
      :order => 'end_at DESC',
      :group => 'terms.id'
  end

  def self.search_by_date_and_category(search, page, category_id, the_date, is_private=false)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and events.is_private = ? and categories.id = ? and start_at < ? and end_at > ?', "%#{search}%", is_private, category_id, end_of_day, start_of_day],
      :order => 'start_at ASC'
  end

    def self.search_has_publisher_by_date_and_category(search, page, category_id, the_date, is_private=false)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ?  and categories_events.category_id = ? and start_at < ? and end_at > ?', "%#{search}%", is_private, category_id, end_of_day, start_of_day],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_publisher_futur_by_date_and_category(search, page, category_id, the_date, is_private=false)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ?  and categories_events.category_id = ? and start_at < ? and end_at > ?  and start_at >= NOW()', "%#{search}%", is_private, category_id, end_of_day, start_of_day],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_publisher_past_by_date_and_category(search, page, category_id, the_date, is_private=false)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :conditions => ['events.name LIKE ? and events.is_private = ?  and categories_events.category_id = ? and start_at < ? and end_at > ?  and start_at <= NOW()', "%#{search}%", is_private, category_id, end_of_day, start_of_day],
      :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :order => 'start_at ASC',
      :group => 'terms.id'
  end

  def self.search_has_no_publisher_by_date_and_category(search, page, per_page, category_id, the_date, is_private=false)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)

      paginate  :per_page => per_page,
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ["events.name LIKE ? and events.is_private = ? and categories.id = ? and start_at < ? and end_at > ?  and events.id not in (select event_id from contributions where role='publisher' and event_id is not null)", "%#{search}%", is_private, category_id, end_of_day, start_of_day],
      :order => 'start_at ASC'
      
  end

#  def self.search_by_user_participation(search, page, per_page, user, is_private=false)
#    paginate  :per_page => per_page,
#      :page => page,
#      :include => [:event],
#      :conditions => ["events.name LIKE ? and events.is_private = ? and start_at >= NOW() and participations.user_id = ?", "%#{search}%", is_private, user.id],
#      :joins => "inner join events on events.id = terms.event_id inner join participations on participations.term_id = terms.id and participations.role='sure' or participations.role='maybe' ",
#      :order => 'start_at ASC'
#  end

  def self.search_by_user_organisms(search, page, per_page, user, is_private=false)
    paginate  :per_page => per_page,
      :page => page,
      :include => [:event],
      :conditions => ["events.name LIKE ? and events.is_private = ? and start_at >= NOW() and organisms_users.user_id = ?", "%#{search}%", is_private, user.id],
      :joins => "inner join events on events.id = terms.event_id 
      inner join contributions on contributions.event_id = events.id
      inner join organisms_users on organisms_users.organism_id = contributions.organism_id",
      :order => 'start_at ASC'
  end


  def self.count_occuring_in_the_day(category_id, the_date, is_private=false)

    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    count 'terms.id', :joins => "inner join events on events.id = terms.event_id inner join contributions on contributions.event_id = events.id and contributions.role='publisher' inner join categories_events on categories_events.event_id = events.id",
      :conditions => ['categories_events.category_id = ? and events.is_private = ? and start_at < ? and end_at > ?', category_id, is_private, end_of_day, start_of_day],
    :distinct => true
  end

  def is_user_participant(user, role)
    result = false
    case role
    when "sure"
      result=true if sure_participants.include?(user)
    when "maybe"
      result=true if maybe_participants.include?(user)
    when "not"
      result=true if not_participants.include?(user)
    end
    return result
  end

  def get_parent_object
    return event
  end

end
