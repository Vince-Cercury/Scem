class Contribution < ActiveRecord::Base
  belongs_to :event
  belongs_to :organism
  belongs_to :publisher,   :class_name => "Organism", :conditions => "contributions.role = 'publisher'"
  belongs_to :organizer,   :class_name => "Organism", :conditions => "contributions.role = 'organizer'"
  belongs_to :partner,   :class_name => "Organism", :conditions => "contributions.role = 'partner'"

end