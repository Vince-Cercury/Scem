class OrganismsUserMailer < ActionMailer::Base

  def creation_notification(admin_or_modo, user, organism, role)
    
    #organism_admin and organism_modo, send this emails
    setup_email(admin_or_modo,user, organism, role)
    @subject    += "Membership request for #{organism.name}"
    @body[:url_member]  = "#{ENV['SITE_URL']}#{organisms_users_path}/accept?organism_id=#{organism.id}&user_id=#{user.id}&role=member"
    @body[:url_moderator]  = "#{ENV['SITE_URL']}#{organisms_users_path}/accept?organism_id=#{organism.id}&user_id=#{user.id}&role=moderator"
    @body[:url_admin]  = "#{ENV['SITE_URL']}#{organisms_users_path}/accept?organism_id=#{organism.id}&user_id=#{user.id}&role=admin"
    @body[:url_refuse]  = "#{ENV['SITE_URL']}#{organisms_users_path}/refuse?organism_id=#{organism.id}&user_id=#{user.id}"

  end

  def activation_notification(user, organism, role)
    #organism_admin and organism_modo, send this emails
    setup_email(user, user, organism, role)
    @subject    += "Membership accepted has a #{role} by #{organism.name}"
    @body[:url]  = "#{ENV['SITE_URL']}#{organisms_path}/#{organism.id}"
  end

  protected
  def setup_email(receiver, user, organism, role)
    @recipients  = "#{receiver.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "[SCEM] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:role] = role
    @body[:organism] = organism
  end
end
