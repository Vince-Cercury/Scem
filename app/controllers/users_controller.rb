class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # Protect these actions behind an admin login
  before_filter :is_admin?, :only => [:destroy, :purge]

  # Protect these actions behind a moderator login
  before_filter :ensure_is_moderator?, :only => [:suspend, :unsuspend]
  #before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  #Protect this action by cheking of logged in AND if owner of the account or admin or moderator for editing
  before_filter :owner_rights?, :only => [:edit, :update, :ask_facebook_info, :other_friends, :save_email]

  before_filter :ensure_authenticated_to_facebook, :only => [:ask_facebook_info, :other_friends]

  #Protect this action by cheking if connected user is admin or moderator or owner or acquaintance
  # TODO: documentation from facebook to see different levels of rights
  before_filter :acquaintance_rights?, :only => [:show]

  def index
    @users = User.search(params[:search], params[:page])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'users_list'
        end
      }
    end
  end

  def show
    find_user


    if @user.facebook_user?
      @to_display_fb_user = Facebooker::User.new(@user.fb_user_id)
      @status_message = @to_display_fb_user.status.message
      @status_time = @to_display_fb_user.status.time
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t("users.update_success")
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = I18n.t("users.create_success")
    else
      flash[:error]  = I18n.t("users.create_error")
      render :action => 'new'
    end
  end

  def ask_facebook_info
      @user = User.find(params[:id])
      respond_to do |format|
        format.html
        format.xml  { render :xml => current_user }
      end

  end

  def other_friends
      @user = User.find(params[:id])
      respond_to do |format|
        format.html
        format.xml  { render :xml => current_user }
      end
  end

  def save_email
    @user = User.find(params[:id])
    
    #we don't want to validate the password
    @user.set_validate_password(false)

    #raise @user.do_we_validate_password?.inspect
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t("users.update_success")
        format.html { redirect_back_or_default('/') }
        format.xml  { head :ok }
      else
        format.html { render :action => "ask_email" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = I18n.t("users.activate_success")
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = I18n.t("activate_code_missing")
      redirect_back_or_default('/')
    else 
      flash[:error]  = I18n.t("activate_not_found")
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

  protected

  def find_user
    @user = User.find_by_id_and_state(params[:id], 'active')
  end


  # Check if logged in user is the same as the one specified
  #
  # will return true if the logged in user is equal as the controlled user (or admin or moderator)
	def owner_rights?
    no_permission_redirection unless current_user && (current_user.id==find_user.id || current_user.has_system_role('moderator'))
  end


  #check if the logged in user is an acquaintance of the user to controll
  def acquaintance_rights?
    allowed_to_view_profile = false
    
    user_to_display = find_user
    if current_user
      if current_user.id==user_to_display.id || current_user.has_system_role('moderator')
        allowed_to_view_profile = true
      else
        #check if both current user and user to display are facebook users in order to use the friends system
        if current_user.facebook_user? && user_to_display.facebook_user?
          current_fb_user = Facebooker::User.new(current_user.fb_user_id)
          if current_fb_user.friends_with?(user_to_display.fb_user_id)
            allowed_to_view_profile = true
          end
        end
      end
    end
    
    not_allowed_to_view_redirection  unless allowed_to_view_profile
  end

  def not_allowed_to_view_redirection
    if current_user
      flash[:error] = I18n.t('users.controller.Not_friend')
      redirect_to users_path
    else
      flash[:error] = I18n.t('users.controller.Not_allowed')
      redirect_to login_path
    end

  end

end
