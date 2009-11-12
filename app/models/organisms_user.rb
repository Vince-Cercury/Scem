class OrganismsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :organism
  belongs_to :member,     :class_name => "Organism", :conditions => "organism_user.role = 'member'"
  belongs_to :moderator,  :class_name => "Organism", :conditions => "organism_user.role = 'moderator'"
  belongs_to :admin,      :class_name => "Organism", :conditions => "organism_user.role = 'admin'"

  include AASM
  aasm_column :state

  aasm_initial_state :initial => :pending

  aasm_state :passive
  aasm_state :pending
  aasm_state :active,  :enter => :do_activate

  aasm_event :register do
    transitions :from => :passive, :to => :pending 
  end

  aasm_event :activate do
    transitions :from => :passive, :to => :active, :guard =>  Proc.new {|org_u| !org_u.role.blank? }
    transitions :from => :pending, :to => :active, :guard =>  Proc.new {|org_u| !org_u.role.blank? }
  end



  def recently_activated?
    @activated
  end


  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
  end

end