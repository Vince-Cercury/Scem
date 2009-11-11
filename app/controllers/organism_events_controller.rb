class OrganismEventsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # GET /galleries
  # GET /galleries.xml
  def index
    @organism = Organism.find(params[:organism_id])
    #@events = @organism.search_events(params[:search], params[:page])

    if params[:period] == "past"
      @terms = Term.search_has_publisher_past_by_organism(params[:search], params[:page], @organism.id)
    else
      @terms = Term.search_has_publisher_futur_by_organism(params[:search], params[:page], @organism.id)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @terms }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/terms/terms_list'
        end
      }
    end
  end
  
end