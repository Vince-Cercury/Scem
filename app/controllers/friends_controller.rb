class FriendsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]

  before_filter :is_logged?
  before_filter :is_facebook_user?



  # GET /terms
  # GET /terms.xml
  def index
    @user = User.find(params[:user_id])
    @to_display_fb_user = Facebooker::User.new(@user.fb_user_id)
    facebook_friends = @to_display_fb_user.friends

    #build a list of SCEM users from the list of Facebook users (if registered on this app)
    @users = Array.new
    facebook_friends = @to_display_fb_user.friends

    facebook_friends.each do |facebook_friend|
      if User.facebook_user_accepted_this_app?(facebook_friend.id)
        @users << User.find_by_fb_user_id(facebook_friend.uid)
      end
    end


    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => @partial_path
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
