# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_facebook_session
  helper_method :facebook_session


  # Check for Logged in User
  #
  # will return true if a User session exists else will redirect to login page '/login'
	def is_logged?
    if logged_in?
      return true
    else
      flash[:error] = 'You have to be logged in to do this.'
      redirect_to login_path
    end
  end

  # Administrator
  #
  # will return true if the logged in user has system role of Administrator('admin')
	def is_admin?
		no_permission_redirection unless self.current_user && self.current_user.has_system_role('admin')
  end

  # Moderator
  #
  # will return true if the logged in user has system role of Moderator('moderator') or Administrator('admin')
	def is_moderator?
    self.current_user && self.current_user.has_system_role('moderator')
	end
  
  def ensure_is_moderator?
    no_permission_redirection unless is_moderator?
	end
  

  # Default Redirection
  #
  # If a User tries to Access the area for which he does not have permission
  #
  # he will be redirected to the default homepage with message "Permission denied'
	def no_permission_redirection
		flash[:error] = "Permission denied"
		redirect_to root_path
	end

  def render_calendar_cell(d)
    puts "#{d.mday} (1)<br />"
    puts "a"
  end


  def time_diff_in_minutes (time)
    diff_seconds = (Time.now - time).round
    diff_minutes = diff_seconds / 60
    return diff_minutes
  end

  
  #this method is used to set some session parameters about the current object
  #this is necesary for the plugin fckeditor which use different
  # upload folder based on these parameters
  def set_session_parent_parameters(current_object)
    session[:parent_type] = current_object.class
    session[:parent_id] = current_object.id
  end

  #polymorphic url to manage or not ?
  def url_for_even_polymorphic(object)
    if(object.class.to_s.eql?('Post'))
      return url_for polymorphic_path([object.get_parent_object, object].flatten)
    else
      return url_for(object)
    end
  end

end
