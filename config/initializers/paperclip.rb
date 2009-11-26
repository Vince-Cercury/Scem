Paperclip.interpolates :parent_root_path do |attachment, style|
  Picture.get_picture_root_path(attachment.instance.parent_type, attachment.instance.parent_id)
end
