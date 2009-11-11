class CommentMailer < ActionMailer::Base

    helper :users

  def to_author_accepted_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
     @subject    += I18n.t('comment_mailer.subject_comment_accepted')
    #@body[:url]  = url_for(parent_object)
  end

  def to_moderators_creation_moderate(user, comment, parent_object)

    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type.#{comment.commentable_type}"))
    @body[:url_activate]  = "#{ENV['SITE_URL']}/comments/activate?id=#{comment.id}"
    @body[:parent_object_url]  = url_for_even_polymorphic(parent_object)
  end

  def to_moderators_creation_notification(user, comment, parent_object)
    setup_email(user, comment, parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type.#{comment.commentable_type}"))
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    
    @body[:parent_object_url]  = url_for_even_polymorphic(parent_object)
  end

  def to_sys_moderators_accepted_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type.#{comment.commentable_type}"))
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/comments/#{comment.id}/edit"
    @body[:parent_object_url]  = url_for_even_polymorphic(parent_object)
  end

  def to_sys_moderators_creation_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type.#{comment.commentable_type}"))
    @body[:url_suspend]  = "#{ENV['SITE_URL']}/comments/suspend?id=#{comment.id}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}/comments/#{comment.id}/edit"
    @body[:parent_object_url]  = url_for_even_polymorphic(parent_object)
  end


  def to_sys_moderators_suspended_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type.#{comment.commentable_type}"))
   @body[:parent_object_url]  = url_for_even_polymorphic(parent_object)
  end


  protected
  
  def setup_email(user, comment, parent_object)
    @recipients  = "#{user.email}"
    @from        = "#{ENV['ADMINEMAIL']}"
    @subject     = "#{ENV['APPNAME']} "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:comment] = comment
    @body[:parent_object] = parent_object
    @content_type = "text/html"
  end

  private

  #polymorphic url to manage or not ?
  def url_for_even_polymorphic(object)
    if(object.class.to_s.eql?('Post'))
      return "#{ENV['SITE_URL']}#{polymorphic_path([object.get_parent_object, object].flatten)}"
    else
      return "#{ENV['SITE_URL']}#{polymorphic_path([object].flatten)}"
    end
  end
end
