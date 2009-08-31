module GalleriesHelper
  def display_gallery_cover(gallery, style)
    if gallery.cover.nil?
      link_to(image_tag("default/gallery/#{style}/1.jpg"), gallery)
    else
      link_to(image_tag(gallery.cover.attached.url(style)), gallery)
    end
  end
end
