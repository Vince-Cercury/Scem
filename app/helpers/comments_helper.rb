module CommentsHelper
  def edit_comment_if_not_too_late(time_posted, comment)
    if logged_in?
      if((time_diff_in_minutes(time_posted) < Integer(ENV['TIME_ALLOW_EDIT_COMMENT']) && comment.user_id==self.current_user.id)or (self.current_user && self.current_user.has_system_role('moderator')))
        result = link_to 'Edit', edit_url_for_even_polymorphic(comment)
        result << "<br />"
      else
        if comment.user_id==self.current_user.id
          "no editing (#{ENV['TIME_ALLOW_EDIT_COMMENT']} min max)<br />"
        end
      end
    end
  end
end
