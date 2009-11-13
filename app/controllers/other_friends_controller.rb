class OtherFriendsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]

  before_filter :is_logged?
  before_filter :is_facebook_user?



  # GET /terms
  # GET /terms.xml
  def index
    @user = User.find(params[:user_id])
    
    
    #build a list of SCEM users from the list of Facebook users (if registered on this app)
    #friends = 
    
    if  @user.facebook_friends_info.nil?
      @facebook_friends = Array.new
    else
      if !params[:search].nil?
        @facebook_friends = Array.new
        @user.facebook_friends_info.each do |a_friend|
          if a_friend['first_name'].downcase.include?(params[:search].downcase) or a_friend['last_name'].downcase.include?(params[:search].downcase)
            @facebook_friends << a_friend
          end
        end
      else
        @facebook_friends = @user.facebook_friends_info
      end
    end
    
    @total_number = @facebook_friends.size
    @facebook_friends = @facebook_friends.paginate :per_page => ENV['PER_PAGE_OTHER_FRIENDS'], :page => params[:page]

   

    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'facebook_users_list'
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
    flash[:error] = I18n.t('other_friends.controller.Feature_not_available')
    redirect_to root_path
  end

end
