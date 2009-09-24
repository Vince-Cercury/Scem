class EventsController < ApplicationController
  

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index, :new, :edit]

  # Protect these actions behind an admin login
  before_filter :is_admin?, :only => [:destroy]#, :purge]

  before_filter :is_logged?, :only => [:new, :create, :edit, :update]

  # Protect these actions behind a moderator login
  # TODO: implement aasm for events
  before_filter :is_granted_to_edit?, :except => [:show, :index, :create, :new]
  

  #Protect this action by cheking of logged in AND if owner of the account or admin or moderator for editing
  #before_filter :organism_admin_or_moderator?, :only => [:new, :edit, :update]

  # GET /events
  # GET /events.xml
  def index

    if params[:type] == 'event_user'
      @events = Event.search_not_have_publisher(params[:search], params[:page])
    else
      @events = Event.search_has_publisher(params[:search], params[:page])
    end

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
    initialize_new_comment(@event)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new


    set_session_parent_pictures_root_path(@event)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    set_session_parent_pictures_root_path(@event)
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.created_by = current_user.id

    
    if params[:type] != 'user_event'
    #associate event to eventual publishers
      contributors = Organism.find(params[:contributions][:publisher_ids])
      contributors.each do |contributor|
        contribution = Contribution.new
        contribution.event_id=@event.id
        contribution.organism_id=contributor.id
        contribution.role="publisher"
        @event.contributions << contribution
      end
    end

    set_session_parent_pictures_root_path(@event)

    #FIXME : put these default parameters in table structure instead
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
    @event.edited_by = current_user.id
    set_session_parent_pictures_root_path(@event)

    #deleting all contributions for this event, whatever the role of the organism
    Contribution.delete_all(["event_id = ?", @event.id])


    create_contribution(:contributions, :publisher_ids, "publisher")
    create_contribution(:contributions, :partner_ids, "partner")
    create_contribution(:contributions, :organizer_ids, "organizer")
    create_contribution(:contributions, :place_ids, "place")
    
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
  #  def destroy
  #    @event = Event.find(params[:id])
  #    @event.destroy
  #
  #    respond_to do |format|
  #      format.html { redirect_to(events_url) }
  #      format.xml  { head :ok }
  #    end
  #  end


  
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
    if current_user
      flash[:error] = "Not allowed to do this."
      redirect_back_or_default('/')
    else
      flash[:error] = "Not allowed to do this. May be log in could help."
      redirect_to login_path
    end

  end

  def not_moderator_of_any_organism
    if current_user
      flash[:error] = "To create an event, you must be at least a moderator or an admin. You can try to create an organism first."
      redirect_back_or_default('/')
    else
      flash[:error] = "Not allowed to do this. May be log in could help."
      redirect_to login_path
    end

  end

end
