
class OrganismObserver < ActiveRecord::Observer
  def after_create(organism)
    organism.reload

    #send an email to the creator
    @organism_creator = User.find(organism.created_by)
    OrganismMailer.deliver_signup_notification_to_organism_admin_or_modo(@organism_creator, organism) if organism.pending? unless @organism_creator.email==""

    #for each system_moderator and system_admin, send signup notification email (contening all organism infos)
    @system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    @system_admins_or_modo.each  do |user|
      OrganismMailer.deliver_signup_notification_to_system_admin_or_modo(user, organism) if organism.pending? unless user.email.blank?
    end
  end

  def after_save(organism)
    organism.reload
    
    #for each organism_moderator and organism_admin, send activation notification email
    @organism_admins_or_modo = organism.admins + organism.moderators
    @organism_admins_or_modo.each  do |user|
      OrganismMailer.deliver_activation_to_organism_admin_or_modo(user, organism) if organism.recently_activated?  unless user.email==""
    end

    #for each system_moderator and system_admin, send activation notification email
    @system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    @system_admins_or_modo.each  do |user|
      OrganismMailer.deliver_activation_to_system_admin_or_modo(user, organism) if organism.recently_activated?  unless user.email==""
    end
  end
end
