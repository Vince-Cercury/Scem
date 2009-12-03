class UserMailer < ActionMailer::Base

  helper :users, ActionView::Helpers::TextHelper

  def simple_email(recipient_email, sender_email, subject, body)
    @recipients =  recipient_email
    @subject    =  subject
    @from       =  sender_email
    @body[:content] =  body
    @sent_on     = Time.now
    @content_type = "text/html"
  end

  def signup_notification(user)
    setup_email(user)
    @subject    += I18n.t('user_mailer.subject_created')
  
    @body[:url]  = "#{ENV['SITE_URL']}/activate_user/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += I18n.t('user_mailer.subject_activated')
    @body[:url]  = "#{ENV['SITE_URL']}/"
  end

  def activation_notification_to_moderators(admin_or_moderator, new_user)
    setup_email(admin_or_moderator)
    @subject    += I18n.t('user_mailer.subject_new_account_activated')
    @body[:new_user]  = new_user
    @body[:url]  = "#{ENV['SITE_URL']}/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "#{ENV['APPNAME']} "
    @sent_on     = Time.now
    @body[:user] = user
    @content_type = "text/html"
  end
end
