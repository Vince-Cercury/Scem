class CommentMailer < ActionMailer::Base

  def to_author_accepted_notification(user, comment, controller)
    setup_email(user, comment)
    @subject    += "Comment accepted"
    @body[:url]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end

  def to_moderators_creation_moderate(user, comment, controller)

    setup_email(user, comment)
    @subject    += "Comment posted for (#{comment.commentable_type})"
    @body[:url_activate]  = "#{ENV['SITE_URL']}/comments/activate?id=#{comment.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end

  def to_moderators_creation_notification(user, comment, controller)
    setup_email(user, comment)
    @subject    += "Comment posted for (#{comment.commentable_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end

  def to_sys_moderators_accepted_notification(user, comment, controller)
    setup_email(user, comment)
    @subject    += "Comment posted for (#{comment.commentable_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/comments/#{comment.id}/edit"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end

  def to_sys_moderators_creation_notification(user, comment, controller)
    setup_email(user, comment)
    @subject    += "Comment posted for (#{comment.commentable_type})"
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/comments/#{comment.id}/edit"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end


  def to_sys_moderators_suspended_notification(user, comment, controller)
    setup_email(user, comment)
    @subject    += "A comment for (#{comment.commentable_type}) has been suspended"
    @body[:url_context]  = "#{ENV['SITE_URL']}/#{controller}/#{comment.commentable_id}"
  end


  protected
  
  def setup_email(user, comment)
    @recipients  = "#{user.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "[SCEM] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:comment] = comment
  end
end
