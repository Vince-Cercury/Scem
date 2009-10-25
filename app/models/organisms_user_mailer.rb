class OrganismsUserMailer < ActionMailer::Base

  helper :users

  def creation_notification(admin_or_modo, user, organism, role, state)
    
    #organism_admin and organism_modo, send this emails
    setup_email(admin_or_modo,user, organism, role)
    @subject    += "Membership request for #{organism.name}"

    @body[:state] = state
    @body[:role] = role
    @body[:url_member]  = url_for(:host => ENV['HOST'], :controller => 'members', :organism_id => organism.id, :user_id => user.id, :role => 'member', :action => 'accept')
    @body[:url_moderator]  = url_for(:host => ENV['HOST'], :controller => 'members', :organism_id => organism.id, :user_id => user.id, :role => 'moderator', :action => 'accept')
    @body[:url_admin]  = url_for(:host => ENV['HOST'], :controller => 'members', :organism_id => organism.id, :user_id => user.id, :role => 'admin', :action => 'accept')
    @body[:url_refuse]  = url_for(:host => ENV['HOST'], :controller => 'members', :organism_id => organism.id, :user_id => user.id, :action => 'refuse')
    
  end

  def activation_notification(user, organism, role)
    #organism_admin and organism_modo, send this emails
    setup_email(user, user, organism, role)
    @subject    += "You are now a #{role} of #{organism.name}"
    @body[:role] = role
    @body[:url]  = "#{ENV['SITE_URL']}#{organism_path(:id => organism.id)}"
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
    @content_type = "text/html"
  end
end
