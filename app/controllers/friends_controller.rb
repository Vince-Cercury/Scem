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
    friends = Array.new
    facebook_friends = @to_display_fb_user.friends

    #raise facebook_friends.inspect
    facebook_friends.each do |facebook_friend|
      #if User.facebook_user_accepted_this_app?(facebook_friend.uid)
      a_friend = User.find_by_fb_user_id(facebook_friend.uid)
      if !a_friend.nil?
        #raise a_friend.login.inspect
        #this allows us simulate a search on an array (usualy down at the model level with active record)
        #because we are not dealing with database, but data from facebooker api
        if !params[:search].nil?
          if a_friend.login.downcase.include?(params[:search].downcase) or a_friend.first_name.downcase.include?(params[:search].downcase) or a_friend.last_name.downcase.include?(params[:search].downcase)
            friends << a_friend
          end
        else
          friends << a_friend
        end
      end
    end
    
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
