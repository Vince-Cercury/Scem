# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

 def get_url_past_or_futur_tab
	if @category.nil?
		return terms_path(:period => @period_link_param)
	else
		return category_path(:id => @category.id, :period => @period_link_param)
	end
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

    prev_month_link = link_to( "#{the_date.last_month.strftime("%B")}", :controller =>"categories", :action => 'show', :id => category_id, :date => "01-#{the_date.last_month.month}-#{the_date.last_month.year}" )
    next_month_link = link_to( "#{the_date.next_month.strftime("%B")}", :controller =>"categories", :action => 'show', :id => category_id, :date => "01-#{the_date.next_month.month}-#{the_date.next_month.year}" )

    calendar(:year => the_date.year, :month => the_date.month, :first_day_of_week => 1, :previous_month_text => prev_month_link, :next_month_text => next_month_link) do |d|
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
    else
      result = 'events'
    end
    return result
  end



end
