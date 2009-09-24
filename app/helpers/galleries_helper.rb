module GalleriesHelper
  def display_gallery_cover(gallery, style)
    if gallery.cover.nil?
      link_to(image_tag("default/gallery/#{style}/1.jpg"), polymorphic_path([gallery.get_parent_object, gallery].flatten))
    else
      link_to(image_tag(gallery.cover.attached.url(style)), polymorphic_path([gallery.get_parent_object, gallery].flatten))
    end
  end
end
