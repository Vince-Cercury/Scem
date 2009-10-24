# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_url_past_or_futur_tab
    if @category.nil?
      return terms_path(:period => @period_link_param, :date => params[:date])
    else
      return category_path(:id => @category.id, :period => @period_link_param, :date => params[:date])
    end
  end


  def get_next_user_terms
    #get the current category or use the general category
    if(controller_name == "categories" && params[:id])
      category_id = params[:id]
    else
      category_id = categories_not_to_display.first.id
    end

    #the_date = parse_params_date_or_now_date
    Term.search_has_no_publisher_futur_by_category('',1,ENV['USER_EVENTS_MAX_RESULTS'], category_id)
  end

  def boolean_to_literal(the_boolean)
    buff=""
    if the_boolean==true
      buff = "Oui"
    else
      buff = "Non"
    end
    return buff
  end



  #display a calendar of a month
  #extract the month and year from a date parameter or use current month
  # with numer of events occuring during this day in brackets
  #use intenrsively the plugin calendar_helper
  def events_calendar_display

    #get the current category or use the general category
    if(controller_name == "categories" && params[:id])
      category_id = params[:id]
    else
      category_id = categories_not_to_display.first.id
    end

    the_date = parse_params_date_or_now_date

    if the_date.year > 2008
      prev_month_link = link_to( l(the_date.last_month, :format => 'only_month'), :controller =>"categories", :action => 'show', :id => category_id, :date => "01-#{the_date.last_month.month}-#{the_date.last_month.year}" )
    end
    if the_date.year < 2020
      next_month_link = link_to( l(the_date.next_month, :format => 'only_month'), :controller =>"categories", :action => 'show', :id => category_id, :date => "01-#{the_date.next_month.month}-#{the_date.next_month.year}" )
    end
    
    calendar(:year => the_date.year, :month => the_date.month, :first_day_of_week => 1, :previous_month_text => prev_month_link, :next_month_text => next_month_link, :the_date => the_date) do |d|
      cell_attrs = {:class => 'day'}

      number_of_events = Term.count_occuring_in_the_day(category_id, d)
      if number_of_events > 0
        cell_text = link_to( "#{d.mday}", :controller =>"categories", :action => 'show', :id => category_id, :date => "#{d.day}-#{d.month}-#{d.year}" )
        cell_text += "<div class='numberEvent'>#{number_of_events}</div>"
        cell_attrs[:class] = 'specialDay'
      else
        cell_text = "#{d.mday}<br />"
        cell_attrs = {:class => 'day'}
      end

      # we use the class 'today' if the day is the one selected
      if (d.year == the_date.year && d.month == the_date.month && d.day == the_date.day)
        cell_attrs = {:class => 'today'}
      end

      [cell_text, cell_attrs]
    end

  end

  def parse_params_date_or_now_date
    #if the date param is not valid, return current date
    if !params[:date].nil?
      Time.parse(params[:date])
    else
      Time.now
    end
  end

  def time_diff_in_minutes (time)
    diff_seconds = (Time.now - time).round
    diff_minutes = diff_seconds / 60
    return diff_minutes
  end

  def get_current_control

    case controller_name
    when 'events'
      result = 'events'
    when 'categories'
      result = 'categories'
    when 'organisms'
      result = 'organisms'
    when 'activities'
      result = 'activities'
    when 'galleries'
      result = 'galleries'
    when 'pictures'
      result = 'pictures'
    when 'users'
      result = 'users'
    else
      result = 'events'
    end
    return result
  end

  #we want to seach only in those models
  #by default, we search into events
  def get_current_search_controller

    case controller_name
    when 'participations'
      result = 'participations'
    when 'events'
      result = 'events'
    when 'organisms'
      result = 'organisms'
    when 'activities'
      result = 'organisms'
    when 'categories'
      result = 'events'
    when 'galleries'
      result = 'galleries'
    when 'users'
      result = 'users'
    when 'friends'
      result = 'friends'
    when 'other_friends'
      result = 'other_friends'
    else
      result = 'events'
    end
    return result
  end

  def get_current_search_model_type

    case controller_name
    when 'participations'
      result = t('search.model_type.participations')
    when 'events'
      result = t('search.model_type.events')
    when 'organisms'
      result = t('search.model_type.organisms')
    when 'activities'
      result = t('search.model_type.organisms')
    when 'categories'
      result = t('search.model_type.events')
    when 'galleries'
      result = t('search.model_type.galleries')
    when 'friends'
      result = t('search.model_type.friends')
    when 'other_friends'
      result = t('search.model_type.other_friends')
    when 'users'
      result = t('search.model_type.users')
    else
      result = t('search.model_type.events')
    end
    return result
  end

  def is_moderator?
    self.current_user && self.current_user.has_system_role('moderator')
	end

  def is_current_object_moderator?(current_object)
    if current_user && current_object.is_user_moderator?(current_user)
      return true
    else
      return false
    end
  end


  def url_for_even_polymorphic(object, options = {})
    
    if(object.get_parent_object)
      if object.get_parent_object.get_parent_object
        if object.get_parent_object.get_parent_object
          return polymorphic_path([object.get_parent_object.get_parent_object.get_parent_object, object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten, options)
        else
          return polymorphic_path([object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten, options)
        end
      else
        return polymorphic_path([object.get_parent_object, object].flatten, options)
      end
    else
      return polymorphic_path([object].flatten, options)
    end
  end

  def edit_url_for_even_polymorphic(object)
    if(object.get_parent_object)
      if object.get_parent_object.get_parent_object
        if object.get_parent_object.get_parent_object
          return edit_polymorphic_path([object.get_parent_object.get_parent_object.get_parent_object, object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten)
        else
          return edit_polymorphic_path([object.get_parent_object.get_parent_object, object.get_parent_object, object].flatten)
        end
      else
        return edit_polymorphic_path([object.get_parent_object, object].flatten)
      end
    else
      return edit_path object
    end
  end

  def new_url_for_even_polymorphic(parent_object, symbol)
    if(parent_object.get_parent_object)
      if parent_object.get_parent_object.get_parent_object
        return new_polymorphic_path([parent_object.get_parent_object.get_parent_object, parent_object.get_parent_object, parent_object, symbol].flatten)
      else
        return new_polymorphic_path([parent_object, symbol].flatten)
      end
    else
      return new_polymorphic_path([parent_object, symbol].flatten)
    end
  end




end
