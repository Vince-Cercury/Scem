class PictureMailer < ActionMailer::Base

  def to_author_accepted_notification(user, picture, controller)
    setup_email(user, picture)
    @subject    += "Picture accepted"
    @body[:url]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end

  def to_moderators_creation_moderate(user, picture, controller)

    setup_email(user, picture)
    @subject    += "Picture posted for (#{picture.parent_type})"
    @body[:url_activate]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/activate"
    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end

  def to_moderators_creation_notification(user, picture, controller)
    setup_email(user, picture)
    @subject    += "Picture posted for (#{picture.parent_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}suspend"
    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end

  def to_sys_moderators_accepted_notification(user, picture, controller)
    setup_email(user, picture)
    @subject    += "Picture posted for (#{picture.parent_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/suspend"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/edit"
    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end

  def to_sys_moderators_creation_notification(user, picture, controller)
    setup_email(user, picture)
    @subject    += "Picture posted for (#{picture.parent_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/suspend"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/edit"
    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end


  def to_sys_moderators_suspended_notification(user, picture, controller)
    setup_email(user, picture)
    @subject    += "A picture for (#{picture.parent_type}) has been suspended"
    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{picture.parent_id}"
  end

#  def to_moderators_updated_notification(user, picture, controller)
#    setup_email(user, picture)
#    @subject    += "Picture updated for (#{picture.parent_type})"
#    @body[:url_suspend]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/suspend"
#    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
#  end

#  def to_sys_moderators_updated_notification(user, picture, controller)
#    setup_email(user, picture)
#    @subject    += "Picture updated for (#{picture.parent_type})"
#    @body[:url_suspend]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/suspend"
#    @body[:url_edit]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}/edit"
#    @body[:url_picture]  = "#{ENV['SITE_URL']}/pictures/#{picture.id}"
#  end


  protected
  
  def setup_email(user, picture)
    @recipients  = "#{user.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "[SCEM] "
    @sent_on     = Time.now
    @content_type = "text/html"
    headers       "Reply-to" => "support@vrails.lebounce.com"
    @body[:user] = user
    @body[:picture] = picture
  end
end
