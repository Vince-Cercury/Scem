module OrganismsHelper
  def display_organism_cover(organism, style)
    link_to(get_organism_picture(organism, style), organism, :title => organism.name)
  end

  def get_organism_picture(organism, style)
    if organism.picture.nil?
      get_default_organism_picture(organism, style)
    else
      if style == "mini"
        image_tag(organism.picture.attached.url(:small), :height => get_mini_height,:alt => organism.name)
      elsif style == "mini_width"
        image_tag(organism.picture.attached.url(:small), :width => get_mini_height,:alt => organism.name)
      else
        image_tag(organism.picture.attached.url(style),:alt => organism.name)
      end
    end
  end

  def get_default_organism_picture(organism, style)
    if style == "mini"
      image_tag("default/organism/small/1.jpg", :height => get_mini_height,:alt => organism.name)
    elsif style == "mini_width"
      image_tag("default/organism/small/1.jpg", :width => get_mini_width,:alt => organism.name)
    else
      image_tag("default/organism/#{style}/1.jpg",:alt => organism.name)
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
    if !organism.street.blank? && !organism.city.blank?
      result = organism.street + ", " + organism.city
    elsif !organism.street.blank?
      result = organism.street
    elsif !organism.city.blank?
      result = organism.city
    end
    return result
  end
end
