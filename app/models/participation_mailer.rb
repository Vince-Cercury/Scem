class ParticipationMailer < ActionMailer::Base

  def creation_notification(admin_or_modo, user, event, term, role)
    
    #organism_admin and organism_modo, send this emails
    setup_email(admin_or_modo,user, event, role)
    @subject    += "Participation of an event notification (#{event.name})"
    @body[:url_event]  = "#{ENV['SITE_URL']}/events/#{event.id}"
    @body[:url_user]  = "#{ENV['SITE_URL']}/users/#{user.id}"
    @body[:url_participants]  = "#{ENV['SITE_URL']}/participations/?term_id=#{term.id}"
  end

  def creation_notification_to_sys(admin_or_modo, user, event, term, role)

    #organism_admin and organism_modo, send this emails
    setup_email(admin_or_modo,user, event, role)
    @subject    += "Participation of an event notification (#{event.name})"
    @body[:url_event]  = "#{ENV['SITE_URL']}/events/#{event.id}"
    @body[:url_user]  = "#{ENV['SITE_URL']}/users/#{user.id}"
    @body[:url_participants]  = "#{ENV['SITE_URL']}/participations/?term_id=#{term.id}"
  end


  protected
  def setup_email(receiver, user, event, role)
    @recipients  = "#{receiver.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "[SCEM] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:receiver] = receiver
    @body[:role] = role
    @body[:event] = event
  end
end
