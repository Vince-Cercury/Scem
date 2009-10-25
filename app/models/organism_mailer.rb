
class OrganismMailer < ActionMailer::Base
  
  helper :users
  
  def signup_notification_to_system_admin_or_modo(admin_or_modo, organism)

    #system_admin and system_modo, send this emails
    setup_email(admin_or_modo, organism)
    @subject    += 'New organism signup'

    @body[:url]  = "#{ENV['SITE_URL']}/activate_organism/#{organism.activation_code}"
  end

  def signup_notification_to_organism_admin_or_modo(admin_or_modo, organism)

    #system_admin and system_modo, send this emails
    setup_email(admin_or_modo, organism)
    @subject    += 'Your organism created'

  end

  def activation_to_system_admin_or_modo(user, organism)
    #system_admin and system_modo, send this emails
    setup_email(user,organism)
    @subject    += "The organism #{organism.name} has been activated!"
    @body[:url]  = "#{ENV['SITE_URL']}#{organisms_path}/#{organism.id}"
  end

  def activation_to_organism_admin_or_modo(user, organism)
    #organism_admin and organism_modo, send this emails
    setup_email(user,organism)
    @subject    += "Your organism #{organism.name} has been activated!"
    @body[:url]  = "#{ENV['SITE_URL']}#{organisms_path}/#{organism.id}"
  end

  protected
  def setup_email(user, organism)
    @recipients  = "#{user.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "[SCEM] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:organism] = organism
    @content_type = "text/html"
  end
end
