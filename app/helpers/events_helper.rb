module EventsHelper

  def get_mini_height
    "36px"
  end

  def display_event_cover(event, style)
    if event.picture.nil?
      link_to(get_default_event_picture(style), event)
    else
      if style == "mini"
        link_to(image_tag(event.picture.attached.url(:small), :height => get_mini_height), event)
      else
        link_to(image_tag(event.picture.attached.url(style)), event)
      end
    end
  end

  def get_default_event_picture(style)
    if style == "mini"
      image_tag("default/event/small/1.jpg", :height => get_mini_height)
    else
      image_tag("default/event/#{style}/1.jpg")
    end
  end

  def get_list_organism_rights_user(user)
    if user.has_system_role('moderator')
      Organism.find_all_by_state('active', :order =>'name')
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

  def is_event_moderator?(event)
    if current_user && event.is_granted_to_edit?(current_user)
      return true
    else
      return false
    end
  end
  
end
