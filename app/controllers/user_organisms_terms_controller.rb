class UserOrganismsTermsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]

  before_filter :is_logged?, :except => [:index]


  # GET /terms
  # GET /terms.xml
  def index
    @user = User.find(params[:user_id])
    
    if params[:period] == "past"
      @terms = Term.search_past_by_user_organisms(params[:search], params[:page], ENV['PER_PAGE'], @user)
    else
      @terms = Term.search_futur_by_user_organisms(params[:search], params[:page], ENV['PER_PAGE'], @user)
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @terms }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'terms_list'
        end
      }
    end
  end

end
