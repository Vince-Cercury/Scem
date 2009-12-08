class EventTermsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index, :show]


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

    # GET /terms/1/edit
  def edit
    @event = Event.find(params[:event_id])
    @term = Term.find(params[:id])
  end

    # PUT /terms/1
  # PUT /terms/1.xml
  def update
    @term = Term.find(params[:id])
    @event = Event.find(params[:event_id])


    respond_to do |format|
      if @term.update_attributes(parse_term_params)
        flash[:notice] = I18n.t('terms.controller.Successfully_updated')
        format.html { redirect_to(url_for_even_polymorphic(@term)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @term.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @current_object = @event = Event.find(params[:event_id])
    @comments = @event.search_comments('', 1, 3)
    #the object comment is needed for displaying the form of new comment
    initialize_new_comment(@event)
    
    @term = Term.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event }
    end
  end

  private

  def parse_term_params
    term_params_parsed = Hash.new

    start_to_parse = params[:term][:start_at] + " " + params[:term][:start_hour]+":"+params[:term][:start_min]
    end_to_parse = params[:term][:end_at] + " " + params[:term][:end_hour]+":"+params[:term][:end_min]

    term_params_parsed[:start_at] = DateTime.strptime(start_to_parse,'%d/%m/%Y %H:%M')
    term_params_parsed[:end_at] = DateTime.strptime(end_to_parse,'%d/%m/%Y %H:%M')
    term_params_parsed[:description] = params[:term][:description]
    
    return term_params_parsed
  end

end