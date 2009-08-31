class EventsController < ApplicationController
  

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # Protect these actions behind an admin login
  before_filter :is_admin?, :only => [:destroy]#, :purge]

  # Protect these actions behind a moderator login
  # TODO: implement aasm for events
  before_filter :is_granted_to_edit?, :except => [:show, :index]
  

  #Protect this action by cheking of logged in AND if owner of the account or admin or moderator for editing
  #before_filter :organism_admin_or_moderator?, :only => [:new, :edit, :update]

  # GET /events
  # GET /events.xml
  def index
    @events = Event.search(params[:search], params[:page])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @events }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'events_list'
        end
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    #current_object is used for comment form
    @current_object = @event = Event.find(params[:id])
    #the object comment is needed for displaying the form of new comment
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])

    #FIXME : put this in table structure instead
    @event.is_charged=false
    @event.is_private=false

    #add the categories not to display in the list of categories of the event
    add_categories_not_to_display(@event)

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    #deleting all contributions for this event, whatever the role of the organism
    Contribution.delete_all(["event_id = ?", @event.id])

    create_contribution(:contributions, :publisher_ids, "publisher")
    create_contribution(:contributions, :partner_ids, "partner")
    create_contribution(:contributions, :organizer_ids, "organizer")
    
    respond_to do |format|
      if @event.update_attributes(params[:event])

        #add the categories not to display in the list of categories of the event
        add_categories_not_to_display(@event)

        flash[:notice] = 'The event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def add_categories_not_to_display(event)
    #add the categories not to display in the list of categories of the event
    categories_not_to_display = Category.find_all_by_to_display(false)
    categories_not_to_display.each do |category|
      event.categories << category unless event.categories.include?(category)
    end
  end



  def create_contribution(key, subkey, role)
    unless(params[key][subkey].nil?)
      contributors = Organism.find(params[key][subkey])
      contributors.each do |contributor|
        contribution = Contribution.new
        contribution.event_id=@event.id
        contribution.organism_id=contributor.id
        contribution.role=role
        contribution.save
      end
    end
  end

  def is_granted_to_edit?
    event = Event.find(params[:id])
    not_granted_redirection unless current_user && event.is_granted_to_edit?(current_user)
  end

  def not_granted_redirection
    flash[:error] = "Not allowed to do this. May be log in could help."
    redirect_to login_path
  end

end
