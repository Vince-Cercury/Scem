class Activity < ActiveRecord::Base
  include SharedMethods
  before_validation :remove_whitespace_from_name
  
  validates_presence_of     :name
  validates_uniqueness_of   :name

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true #, :reserved => ["new","edit"]

  has_and_belongs_to_many :organisms, :conditions => ['state=?', 'active']

end
