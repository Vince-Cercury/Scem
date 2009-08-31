module OrganismsHelper
  def display_organism_cover(organism, style)
    if organism.picture.nil?
      link_to(image_tag("default/organism/#{style}/1.jpg"), organism)
    else
      link_to(image_tag(organism.picture.attached.url(style)), organism)
    end
  end
end
