class FriendsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]

  before_filter :is_logged?
  before_filter :is_facebook_user?



  # GET /terms
  # GET /terms.xml
  def index
    @user = User.find(params[:user_id])

    friends = FacebookTools.get_user_friends(@user, params[:search])
    
    @users = friends.paginate :per_page => ENV['PER_PAGE'], :page => params[:page]
    

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

  private

  def is_facebook_user?
    @user = User.find(params[:user_id])
    not_facebook_user_redirection unless @user.facebook_user?
  end
  
  def not_facebook_user_redirection
    flash[:error] = "This feature is not available for users that aren't on Facebook"
    redirect_to root_path
  end

end
