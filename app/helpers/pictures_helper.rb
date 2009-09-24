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

end
