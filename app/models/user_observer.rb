class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.reload
    UserMailer.deliver_signup_notification(user) unless user.email==""
  end

  def after_save(user)
    user.reload
    

    UserMailer.deliver_activation(user) if user.recently_activated?  unless user.email==""
  
    #for each system_moderator and system_admin, send an email to notify that a new user has activated his account
    @system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    @system_admins_or_modo.each  do |moderator_or_admin|
      UserMailer.deliver_activation_notification_to_moderators(moderator_or_admin, user) if user.recently_activated?  unless moderator_or_admin.email==""
    end

  end
end