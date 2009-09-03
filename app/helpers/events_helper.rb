module EventsHelper
  def display_event_cover(event, style)
    if event.picture.nil?
      link_to(get_default_event_picture(style), event)
    else
      link_to(image_tag(event.picture.attached.url(style)), event)
    end
  end

  def get_default_event_picture(style)
     image_tag("default/event/#{style}/1.jpg")
  end

  def get_list_organism_rights_user(user)
    if user.has_system_role('moderator')
      Organism.all
    else
      user.is_admin_or_moderator_of
    end
  end

 def display_event_action
    case controller_name
    when 'events'
      result = 'profil'
    when 'galleries'
      result = 'galleries'
    when 'participants'
      result = 'participants'
    end
    return result
  end

  def is_event_admin?(event)
    if current_user && event.is_user_admin?(current_user)
      return true
    else
      return false
    end
  end
  
end
