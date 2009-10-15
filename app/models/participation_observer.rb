class ParticipationObserver < ActiveRecord::Observer
  def after_create(participation)
    participation.reload
    event = participation.term.event
    @list_moderators = event.get_moderators_list
    user = participation.user

    #for each _organism_moderator and organism_admin, send signup notification email
    @list_moderators.each  do |admin_or_modo|
      ParticipationMailer.deliver_creation_notification(admin_or_modo, user, event, participation.term, participation.role) unless user.email==""
    end

    #for each sys_moderator and sys_admin, send signup notification email
    @list_sys_moderators = get_list_sys_admins_or_modo
    @list_sys_moderators.each  do |admin_or_modo|
      ParticipationMailer.deliver_creation_notification_to_sys(admin_or_modo, user, event, participation.term, participation.role) unless user.email==""
    end
  end

  #  def after_save(participation)
  #    participation.reload
  #    organism = participation.organism
  #    user = organism.user
  #
  #    OrganismsUserMailer.deliver_activation_notification(user, organism, participation.role)
  #
  #  end

  private
  def get_list_sys_admins_or_modo
    list_sys_moderators = Array.new
    #for each system_moderator and system_admin, send signup notification email (contening picture infos)
    system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    system_admins_or_modo.each  do |user|
      #if !@list_recipients.include?(user)
      list_sys_moderators << user
      #end
    end
    return  list_sys_moderators
  end
end

