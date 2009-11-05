class EventTermsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]


  def index
    @event = Event.find(params[:event_id])
    @terms = @event.terms

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @terms }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/events/terms'
        end
      }
    end
  end
  
end