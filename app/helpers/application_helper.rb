# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_page_title
    result = ENV['APPNAME']
    if @category && controller_name == 'categories'
       if @category.name
          result += " - " + @category.name
      end
    end
    if controller_name == 'activities'
      if @activity
        if @activity.name
          result += " - " + @activity.name
        end
      else
        result += " - " + t('Directory')
      end
    end
    if @event && controller_name == 'events'
      if @event.name
        result += " - " + @event.name
      end
    end
    if @organism && controller_name == 'organisms'
      if @organism.name
        result += " - " + @organism.name
      end
    end
    if controller_name == 'galleries'
      if  @gallery
        if @gallery.name 
          result += " - " + @gallery.name
        end
      else
        result += " - " + t('Galleries')
      end
    end
    if  controller_name == 'users'
      if @user
        if get_user_name_or_pseudo(@user)
          result += " - " + get_user_name_or_pseudo(@user)
        end
      else
        result += " - " + t('Users')
      end
    end
    if controller_name == 'terms' || controller_name == 'events'
      if !@event
        result += " - " + t('Events')
      end
    end
    return result + " - " + ENV['AREA']
  end

  def get_url_futur_tab
    if @category.nil?
      return terms_path(:period => 'futur', :date => params[:date])
    else
      return category_path(@category, :period => 'futur', :date => params[:date])
    end
  end

  def get_url_past_tab
    if @category.nil?
      return terms_path(:period => 'past', :date => params[:date])
    else
      return category_path(@category, :period => 'past', :date => params[:date])
    end
  end

  def get_url_past_or_futur_tab
    if @category.nil?
      return terms_path(:period => @period_link_param, :date => params[:date])
    else
      return category_path(@category, :period => @period_link_param, :date => params[:date])
    end
  end


  def get_next_user_participations(max_results)
    #the_date = parse_params_date_or_now_date
    current_user.search_participate_in_futur('', 1, max_results)
  end

  def get_next_curent_user_organisms_terms(max_results)
    if current_user
      get_next_user_organisms_futur_terms(current_user, max_results)
    end
  end

  def get_next_user_organisms_futur_terms(user, max_results)
    #the_date = parse_params_date_or_now_date
    Term.search_futur_by_user_organisms('',1,max_results, user)
  end

  def count_next_user_organisms_terms(user)
    Term.count_by_user_organisms('', user)
  end

  def get_next_events(max_results)
    Term.search_has_publisher_futur('', 1, max_results)
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

    if params[:category_id]
      current_category = Category.find(params[:category_id])
      if params[:id]
        the_date = Time.parse(params[:id])
      else
        the_date = parse_params_date_or_now_date
      end
    else
      #get the current category or use the general category
      if(controller_name == "categories" && params[:id])
        current_category = Category.find(params[:id])
      else
        current_category = categories_not_to_display.first
      end
      the_date = parse_params_date_or_now_date
    end


    
    
    complete = "$('spinner-cal').hide(); " + "$('the-cal').show()"
    loading = "$('spinner-cal').show(); " + "$('the-cal').hide(); "

   
    if the_date.year > 2008
      prev_date = "01-#{the_date.last_month.month}-#{the_date.last_month.year}"
      prev_month_link = link_to_remote( l(the_date.last_month, :format => 'only_month'),
        :url => { :controller => "calendar",
          :action => "generate", :category_id => current_category.id, :date => prev_date, :no_day_selection => true},
        :loading => loading, :complete => complete)
      #prev_month_link = link_to( l(the_date.last_month, :format => 'only_month'), category_path(current_category, :date => "01-#{the_date.last_month.month}-#{the_date.last_month.year}" ))
      #raise prev_month_link.inspect
    end
    if the_date.year < (Time.now.year+2)
      next_date = "01-#{the_date.next_month.month}-#{the_date.next_month.year}"
      next_month_link = link_to_remote( l(the_date.next_month, :format => 'only_month'),  :url => { :controller => "calendar",
          :action => "generate", :category_id => current_category.id, :date => next_date, :no_day_selection => true}, :loading => loading, :complete => complete)
      #next_month_link = link_to( l(the_date.next_month, :format => 'only_month'), category_path(current_category, :date =>  "01-#{the_date.next_month.month}-#{the_date.next_month.year}" ))
    end
    
    calendar(:year => the_date.year, :month => the_date.month, :first_day_of_week => 1, :previous_month_text => prev_month_link, :next_month_text => next_month_link, :the_date => the_date) do |d|
      cell_attrs = {:class => 'day'}
      
      number_of_events = Term.count_occuring_in_the_day(current_category.id, d)
      if number_of_events > 0 
        cell_text = "<div class='dayEvent'>"
        cell_text += link_to( "#{d.mday}", category_date_path(current_category, :id => "#{d.day}-#{d.month}-#{d.year}" ))
        cell_text += "</div><div class='numberEvent'>#{number_of_events}</div>"

        cell_attrs[:class] = 'specialDay'
      else
        cell_text = "#{d.mday}<br />"
        cell_attrs = {:class => 'day'}
      end

      # we use the class 'today' if the day is the one selected
      if !params[:no_day_selection]
        if (d.year == the_date.year && d.month == the_date.month && d.day == the_date.day)
          cell_attrs = {:class => 'today'}
        end
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
#  def get_current_search_path
#
#    case controller_name
#    when 'participations'
#      result = url_for('participations')
#    when 'events'
#      result = url_for('events')
#      if @event
#        result = url_for(:controller => 'events', :action => 'index')
#      end
#    when 'organisms'
#      result = url_for('organisms')
#      if @organism
#        result = url_for(:controller => 'organisms', :action => 'index')
#      end
#    when 'activities'
#      if @activity
#        result = url_for(@activity)
#      else
#        result = url_for('organisms')
#      end
#    when 'categories'
#      if @category
#        result = url_for(@category)
#        #result = category_path(@category, :period => params[:period])
#      else
#        result = url_for('events')
#      end
#    when 'galleries'
#      result = url_for('galleries')
#    when 'users'
#      result = url_for('users')
#    when 'friends'
#      result = url_for('friends')
#    when 'other_friends'
#      result = url_for('other_friends')
#    else
#      result = url_for('events')
#    end
#    return result
#  end

#  def get_current_search_model_type
#
#    case controller_name
#    when 'participations'
#      result = t('search.model_type.participations')
#    when 'events'
#      result = t('search.model_type.events')
#    when 'organisms'
#      result = t('search.model_type.organisms')
#    when 'activities'
#      result = t('search.model_type.organisms')
#    when 'categories'
#      result = t('search.model_type.events')
#    when 'galleries'
#      result = t('search.model_type.galleries')
#    when 'friends'
#      result = t('search.model_type.friends')
#    when 'other_friends'
#      result = t('search.model_type.other_friends')
#    when 'users'
#      result = t('search.model_type.users')
#    else
#      result = t('search.model_type.events')
#    end
#    return result
#  end

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
