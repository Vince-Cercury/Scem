module GalleriesHelper
  def display_gallery_cover(gallery, style)
    if gallery.cover.nil?
      link_to(image_tag("default/gallery/#{style}/1.png",:alt => gallery.name), polymorphic_path([gallery.get_parent_object, gallery].flatten), :title => gallery.name)
    else
      link_to(image_tag(gallery.cover.attached.url(style),:alt => gallery.name), polymorphic_path([gallery.get_parent_object, gallery].flatten), :title => gallery.name)
    end
  end 

  def is_gallery_moderator?(gallery)
    if current_user && gallery.is_user_moderator?(current_user)
      return true
    else
      return false
    end
  end

  def is_allowed_add_picture(gallery)
    if current_user && gallery.is_user_moderator?(current_user) || gallery.is_user_allowed_add_picture(current_user)
      return true
    else
      return false
    end
  end

  def get_cover_and_random_pics(gallery, number)
    results = Array.new
    if gallery.defined_cover
      results << gallery.cover
      number = number -1
    end
    if gallery.get_rand_pics_not_cover(number)
      results += gallery.get_rand_pics_not_cover(number)
    end
  end
end
