module EventsHelper

  def get_mini_height
    "36px"
  end

  def get_mini_width
    "36px"
  end

  def display_event_cover(event, style)
    if event.picture.nil?
      link_to(get_default_event_picture(event,style), event, :title => event.name)
    else
      if style == "mini"
        link_to(image_tag(event.picture.attached.url(:small), :height => get_mini_height,:alt => event.name), event, :title => event.name)
      elsif style == "mini_width"
        link_to(image_tag(event.picture.attached.url(:small), :width => get_mini_height,:alt => event.name), event, :title => event.name)
      else
        link_to(image_tag(event.picture.attached.url(style),:alt => event.name), event, :title => event.name)
      end
    end
  end



  def display_term_cover(term, style)
    if term.event.picture.nil?
      link_to(get_default_event_picture(term.event,style), url_for_even_polymorphic(term), :title => term.event.name)
    else
      if style == "mini"
        link_to(image_tag(term.event.picture.attached.url(:small), :height => get_mini_height,:alt => term.event.name), url_for_even_polymorphic(term), :title => term.event.name)
      elsif style == "mini_width"
        link_to(image_tag(term.event.picture.attached.url(:small), :width => get_mini_height,:alt => term.event.name), url_for_even_polymorphic(term), :title => term.event.name)
      else
        link_to(image_tag(term.event.picture.attached.url(style),:alt => term.event.name), url_for_even_polymorphic(term), :title => term.event.name)
      end
    end
  end

  def get_default_event_picture(event, style)
    if style == "mini"
      image_tag("default/event/small/1.jpg", :height => get_mini_height,:alt => event.name)
    elsif style == "mini_width"
      image_tag("default/event/small/1.jpg", :width => get_mini_width,:alt => event.name)
    else
      image_tag("default/event/#{style}/1.jpg",:alt => event.name)
    end
  end

  def get_list_organism_rights_user(user)
    #if user.has_system_role('moderator')
    # Organism.find_all_by_state('active', :order =>'name')
    #else
    user.is_admin_or_moderator_of
    #end
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

  def displayable_categories_links(event)
    result = ""
    event.categories.each do |category|
      if category.to_display
        result += link_to(category.name, url_for(category_path(category))) + "&nbsp";
      end
    end
    if result == ""
      result = t("events.no_categories")
    end
    return result
  end

  def fields_for_term(term, &block)
    prefix = term.new_record? ? 'new' : 'existing'
    fields_for("event[#{prefix}_term_attributes][]", term, &block)
  end

  def add_term_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :terms, :partial => 'term', :object => Term.new
    end
  end

  def fields_for_organizer(event, organizer, &block)
    prefix = event.organizers.include?(organizer) ? 'existing' : 'new'
    fields_for("event[#{prefix}_organizer_attributes][]", organizer, &block)
  end

  def add_organizer_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :organizers, :partial => 'organizer', :object => Organism.new
    end
  end

  def fields_for_partner(event, partner, &block)
    prefix = event.partners.include?(partner) ? 'existing' : 'new'
    fields_for("event[#{prefix}_partner_attributes][]", partner, &block)
  end

  def add_partner_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :partners, :partial => 'partner', :object => Organism.new
    end
  end

  def get_event_location(event)
    if event.places.size > 0
      if !event.places.first.name.blank?
        location = event.places.first.name
      end
    end
    if !event.location.blank?
      location =event.location
    end
    return location
  end

  def get_event_street(event)
    if event.places.size > 0
      if !event.places.first.street.blank?
        street = event.places.first.street
      end
    end
    if !event.street.blank?
      street = event.street
    end
    return street
  end

  def get_event_city(event)
    if event.places.size > 0
      if !event.places.first.city.blank?
        city = event.places.first.city
      end
    end
    if !event.city.blank?
      city = event.city
    end
    return city 
  end

  def get_event_description_long_or_term_description
    if @term
      if !@term.description.blank?
        return @term.description
      end
    end
    if @event
      if !@event.description_long.blank?
        return @event.description_long
      end
    end
  end

  def get_event_description_short_or_term_description
    if @term
      if !@term.description.blank?
        return @term.description
      end
    end
    if @event
      if !@event.description_short.blank?
        return @event.description_short
      end
    end
  end

  def get_event_if_term_url(term)
    event = term.event
    if event.terms.size == 0
      return url_for(event)
    elsif event.terms.size == 1
      return url_for(event)
    else
      return url_for_even_polymorphic(term)
    end
  end

  def get_event_place_as_string(event)
    result = ""
    if !get_event_location(event).blank? && !get_event_street(event).blank? && !get_event_city(event).blank?
      result = get_event_location(event) + ", " + get_event_street(event) + ", " + get_event_city(event)
    elsif !get_event_street(event).blank? && !get_event_city(event).blank?
      result = get_event_street(event) + ", " + get_event_city(event)
    elsif !get_event_location(event).blank?
      result = get_event_location(event)
    elsif !get_event_street(event).blank?
      result = get_event_street(event)
    elsif !get_event_city(event).blank?
      result = get_event_city(event)
    end
    return result
  end

  def get_event_address_as_string(event)
    result = ""
    if !get_event_street(event).blank? && !get_event_city(event).blank?
      result = get_event_street(event) + ", " + get_event_city(event)
    elsif !get_event_street(event).blank?
      result = get_event_street(event)
    elsif !get_event_city(event).blank?
      result = get_event_city(event)
    end
    return result
  end
end
