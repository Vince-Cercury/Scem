class MapsController < ApplicationController
  def index

    @address_located = false

    if params[:organism_id]
      @organism = Organism.find(params[:organism_id])
      @header = '/organisms/header'

      address_name = @organism.name
      if @organism.street && @organism.city
        address_to_locate = @organism.street + ", " + @organism.city
      elsif @organism.street
        address_to_locate = @organism.street
      elsif @organism.city
        address_to_locate = @organism.city
      end
    end

    if params[:event_id]
      @event = Event.find(params[:event_id])
      @header = '/events/header'

      address_name = get_event_location(@event)
      if get_event_street(@event) && get_event_city(@event)
        address_to_locate = get_event_street(@event) + ", " + get_event_city(@event)
      elsif get_event_street(@event)
        address_to_locate = get_event_street(@event)
      elsif get_event_city(@event)
        address_to_locate = get_event_city(@event)
      end

      #if the event got only one terme defined, inject it in views
      if @event.terms.size == 1
        @term = @event.terms.first
      end
    
    end
    

      
    #raise results.inspect
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)

    #@map.overlay_init(GMarker.new([75.6,-42.467],:title => "Hello", :info_window => "Info! Info!"))

    if address_to_locate
      results = Geocoding::get(address_to_locate)
      if results
        if results[0]
          coord = results[0].latlon
          if results.status == Geocoding::GEO_SUCCESS
            @map.center_zoom_init(coord, 15)
            @map.overlay_init(GMarker.new(coord,:title => address_name,:info_window => "#{address_name} <br />#{address_to_locate}"))
            @address_located = true
          end
        end
      end
    end
    
    if !@address_located
      flash['error'] = I18n.t("map.not_found")
      @map.center_zoom_init([ENV['AREA_LATITUDE'],ENV['AREA_LONGITUDE']], 12)
    end
  end

  private

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
end
