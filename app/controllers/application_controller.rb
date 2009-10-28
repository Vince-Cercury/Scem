# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem

  self.send(:skip_before_filter, :verify_authenticity_token)  if :facebook_uninstall_user_request?

  
  rescue_from Facebooker::Session::SessionExpired, :with => :facebook_session_expired


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_facebook_session
  helper_method :facebook_session

  before_filter :set_locale

  def self.facebook_uninstall_user_request?
    return true if params.include?('fb_sig_uninstall') && params['fb_sig_uninstall'] == '1'
    return false
  end

  def facebook_session_expired
    clear_fb_cookies!
    clear_facebook_session_information
    reset_session # remove your cookies!
    flash[:error] = "Your facebook session has expired. Please log in again ..."
    redirect_to login_path
  end


  def set_locale
    available = %w{fr-FR en-US}

    locale = params[:locale] || request.compatible_language_from(available) #'en-US'
    I18n.locale = locale
    I18n.load_path += Dir[ File.join(RAILS_ROOT, 'lib', 'locale', '*.{rb,yml}') ]
  end


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
  def set_session_parent_pictures_root_path(parent_object)
    session[:parent_pictures_root_path] = parent_object.get_picture_root_path
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

  def initialize_new_comment(parent_object)
    @comment = Comment.new
    @comment.commentable_type = parent_object.class.to_s
    @comment.commentable_id = parent_object.id
  end

  def get_user_name_or_pseudo(user)
    if user.facebook_user?
      return user.first_name + " " + user.last_name
    else
      return user.login
    end
  end
  
end
