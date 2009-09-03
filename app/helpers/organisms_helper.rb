module OrganismsHelper
  def display_organism_cover(organism, style)
    if organism.picture.nil?
      link_to(image_tag("default/organism/#{style}/1.jpg"), organism)
    else
      link_to(image_tag(organism.picture.attached.url(style)), organism)
    end
  end

  def display_organism_action
    case controller_name
    when 'organisms'
      result = 'profil'
    when 'galleries'
      result = 'galleries'
    when 'members'
      result = 'members'
    end
    return result
  end

  def is_organism_admin?(organism)
    if current_user && organism.is_user_admin?(current_user)
      return true
    else
      return false
    end
  end

end
