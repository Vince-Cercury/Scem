module CommentsHelper
  def edit_comment_if_not_too_late(time_posted, comment)

    if logged_in?
      if((time_diff_in_minutes(time_posted) < Integer(ENV['TIME_ALLOW_EDIT_COMMENT']) && comment.user_id==self.current_user.id)or (self.current_user && self.current_user.has_system_role('moderator')))
        #result = link_to 'Edit', edit_url_for_even_polymorphic(comment)

        complete = "$('edit-comment-spinner_#{comment.id}').hide(); " + "$('comment_#{comment.id}-content').show();" #+ "$('comment__text_editor').enable()" #+ "$('form-comment').show()"  %>
        loading = "$('edit-comment-spinner_#{comment.id}').show(); " + "$('comment_#{comment.id}-content').hide();" #+ "$('comment__text_editor').disable()" #+ "$('form-comment').hide(); " %>

        result = link_to_remote(t('comments.content.Edit'), :url => url_for( :controller => "comments", :action => "edit", :id => nil,:comment_id=> comment.id),:loading => loading, :complete => complete)
        result += "<br />"
      else
        if comment.user_id==self.current_user.id
          "no editing (#{ENV['TIME_ALLOW_EDIT_COMMENT']} min max)<br />"
        end
      end
    end
  end


  def suspend_comment_if_allowed(comment)

    if logged_in?
      if((comment.user_id==self.current_user.id)or (self.current_user && self.current_user.has_system_role('moderator')))
        #result = link_to 'Edit', edit_url_for_even_polymorphic(comment)

        complete = "$('edit-comment-spinner_#{comment.id}').hide(); " + "$('comment_#{comment.id}-content').show();" #+ "$('comment__text_editor').enable()" #+ "$('form-comment').show()"  %>
        loading = "$('edit-comment-spinner_#{comment.id}').show(); " + "$('comment_#{comment.id}-content').hide();" #+ "$('comment__text_editor').disable()" #+ "$('form-comment').hide(); " %>

        link_to_remote(t('comments.content.Suspend'), :url => url_for( :controller => "comments", :action => "remote_suspend", :id => nil,:comment_id=> comment.id),:loading => loading, :complete => complete)
      end
    end
  end
end
