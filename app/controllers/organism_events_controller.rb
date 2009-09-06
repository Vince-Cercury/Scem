class OrganismEventsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # GET /galleries
  # GET /galleries.xml
  def index
    @organism = Organism.find(params[:organism_id])
    @events = @organism.search_events(params[:search], params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/events/events_list'
        end
      }
    end
  end
  
end