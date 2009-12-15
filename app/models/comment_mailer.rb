class CommentMailer < ActionMailer::Base

    helper :users

  def to_author_accepted_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
     @subject    += I18n.t('comment_mailer.subject_comment_accepted')
    #@body[:url]  = url_for(parent_object)
  end

  def to_moderators_creation_moderate(user, comment, parent_object)

    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_posted',:type =>  I18n.t("type_no_html.#{comment.commentable_type}"))
    @body[:url_activate]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'activate')}"
    @body[:parent_object_url]  = ENV['SITE_URL']+url_for_even_polymorphic(parent_object)
  end

  def to_moderators_creation_notification(user, comment, parent_object)
    setup_email(user, comment, parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_posted',:type =>  I18n.t("type_no_html.#{comment.commentable_type}"))
    @body[:url_suspend]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'suspend')}"
    
    @body[:parent_object_url]  = ENV['SITE_URL']+url_for_even_polymorphic(parent_object)
  end

  def to_sys_moderators_accepted_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_accepted')
    @body[:url_suspend]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'suspend')}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'edit')}"
    @body[:parent_object_url]  = ENV['SITE_URL']+url_for_even_polymorphic(parent_object)
  end

  def to_sys_moderators_creation_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_posted',:type =>  I18n.t("type_no_html.#{comment.commentable_type}"))
    @body[:url_suspend]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'suspend')}"
    @body[:url_edit]  = "#{ENV['SITE_URL']}#{url_for_even_polymorphic(comment,:action => 'edit')}"
    @body[:parent_object_url]  = ENV['SITE_URL']+url_for_even_polymorphic(parent_object)
  end


  def to_sys_moderators_suspended_notification(user, comment, parent_object)
    setup_email(user, comment,parent_object)
    @subject    += I18n.t('comment_mailer.subject_comment_suspended',:type =>  I18n.t("type_no_html.#{comment.commentable_type}"))
   @body[:parent_object_url]  = ENV['SITE_URL']+url_for_even_polymorphic(parent_object)
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
  def url_for_even_polymorphic(object, options = {})
    if(object.get_parent_object)
      if object.get_parent_object.get_parent_object
        if object.get_parent_object.get_parent_object
          return polymorphic_path([object.get_parent_object.get_parent_object.get_parent_object, object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten, options)
        else
          return polymorphic_path([object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten, options)
        end
      else
        return polymorphic_path([object.get_parent_object, object].flatten, options)
      end
    else
      return polymorphic_path([object].flatten, options)
    end
  end
  
end
