class Term < ActiveRecord::Base

  validates_datetime :start, :after => Proc.new { Time.now },
    :after_message => "date must be in the future"


  validates_datetime :end, :after => Proc.new { Time.now },
    :after_message => "date must be in the future"


  validates_datetime :start,
    :before => :end,
    :before_message => "must be before end"

  
  belongs_to :event

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

  def self.search_futur(search, page)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ :event],
      :conditions => ['events.name LIKE ? and terms.start > NOW()', "%#{search}%"],
      :order => 'start ASC'
  end

  def self.search_past(search, page)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ :event],
      :conditions => ['events.name LIKE ? and start <= NOW() ', "%#{search}%"],
      :order => 'start DESC'
  end

  def self.search_futur_by_category(search, page, category_id)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and start >= NOW() and categories.id = ?', "%#{search}%", category_id],
      :order => 'start ASC'
  end

  def self.search_past_by_category(search, page, category_id)
    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and start <= NOW() and categories.id = ?', "%#{search}%",  category_id],
      :order => 'start DESC'
  end

  def self.search_by_date_and_category(search, page, category_id, the_date)
    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    paginate  :per_page => ENV['PER_PAGE'],
      :page => page,
      :include => [ {:event => :categories}],
      :conditions => ['events.name LIKE ? and categories.id = ? and start < ? and end > ?', "%#{search}%", category_id, end_of_day, start_of_day],
      :order => 'start ASC'
  end


  def self.count_occuring_in_the_day(category_id, the_date)

    #preparing 2 datetime dates from year, month, day
    #one at 00h00, the other at 23h59
    start_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 0, 0, 0).utc.to_s(:db)

    end_of_day = DateTime.new(the_date.year, the_date.month, the_date.day, 23, 59, 59).utc.to_s(:db)


    count :include => [ {:event => :categories}],
      :conditions => ['categories.id = ? and start < ? and end > ?', category_id, end_of_day, start_of_day]
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

end
