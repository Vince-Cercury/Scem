module OrganismsHelper
  def display_organism_cover(organism, style)
    if organism.picture.nil?
      link_to(image_tag("default/organism/#{style}/1.jpg",:alt => organism.name), organism, :title => organism.name)
    else
      link_to(image_tag(organism.picture.attached.url(style),:alt => organism.name), organism, :title => organism.name)
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

    def get_organism_address_as_string(organism)
    result = ""
      if organism.street && organism.city
        result = organism.street + ", " + organism.city
      elsif organism.street
        result = organism.street
      elsif organism.city
        result = organism.city
      end
    return result
  end
end
