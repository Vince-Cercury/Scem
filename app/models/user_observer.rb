class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.reload
    UserMailer.deliver_signup_notification(user) if user.email!=""  unless user.email.nil?
  end

  def after_save(user)
    user.reload
    UserMailer.deliver_activation(user) if user.recently_activated? and user.email!=""  unless user.email.nil?
  end
end