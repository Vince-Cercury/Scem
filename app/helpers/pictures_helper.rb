module PicturesHelper

  def get_picture_polymorphic_parent_url(picture)

    if(picture.parent_type == 'Event' or picture.parent_type == 'Organism')
      return url_for(picture.get_parent_object)
    elsif picture.parent_type == 'Gallery'
       return polymorphic_path([picture.get_parent_object.get_parent_object, picture.get_parent_object].flatten)
    end
  end

  def get_edit_picture_polymorphic_parent_url(picture)

    if(picture.parent_type == 'Event' or picture.parent_type == 'Organism')
      return edit_polymorphic_path([picture.get_parent_object, picture].flatten)
    elsif picture.parent_type == 'Gallery'
       return edit_polymorphic_path([picture.get_parent_object.get_parent_object, picture.get_parent_object, picture].flatten)
    end
  end

  def is_picture_moderator?(picture)
    if current_user
      if picture.creator_id==current_user.id
        return true
      end
      if picture.is_user_moderator?(current_user)
        return true
      end
    end
    return false
  end

end
