class EventsController < ApplicationController

  include TermsHelper

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # Protect these actions behind an admin login
  before_filter :is_granted_to_edit?, :only => [:destroy]#, :purge]

  # before_filter :is_logged?, :only => [:new, :create, :edit, :update]

  before_filter :is_granted_to_create, :only => [:new, :create]

  # Protect these actions behind a moderator login
  before_filter :is_granted_to_edit?, :except => [:show, :index, :create, :new, :share, :do_share]

  before_filter :is_granted_to_view?, :only => [:show]


  before_filter :is_logged?, :only => [:share]
  #at the moment, friends are managed with Facebook APIshare

  before_filter :is_facebook_user?, :only => [:share]
  

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
    @comments = @event.search_comments('', 1, 3)
    #the object comment is needed for displaying the form of new comment
    initialize_new_comment(@event)

    #if the event got only one terme defined, inject it in views
    if @event.terms.size == 1
      @term = @event.terms.first
    end
    
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    @event.terms.build


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
      if @event.activate! #@event.save
        
        flash[:notice] = I18n.t('events.controller.Successfully_created')
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

    params[:event][:existing_term_attributes] ||= {}

    #deleting all contributions for this event, whatever the role of the organism
    Contribution.delete_all(["event_id = ?", @event.id])


    create_contribution(:contributions, :publisher_ids, "publisher")
    create_contribution(:contributions, :partner_ids, "partner")
    create_contribution(:contributions, :organizer_ids, "organizer")
    create_contribution(:contributions, :place_ids, "place")

    #hack: do not consider categories id made of hash ['_all'] => id. Problem comes from Swapselect
    if params[:event][:category_ids]
      category_ids = Array.new
      params[:event][:category_ids].each do |id|
        if !id.include? "_all"
          category_ids << id
        end
      end
      params[:event][:category_ids] = category_ids
    end
    
    respond_to do |format|
      if @event.update_attributes(params[:event])

        #add the categories not to display in the list of categories of the event
        add_categories_not_to_display(@event)

        flash[:notice] = I18n.t('events.controller.Successfully_updated')
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
    event = Event.find(params[:id])

    destroyable = true

    if(event.galleries.size>0)
      destroyable = false
    end

    if event.comments.size>0
      destroyable = false
    end

    cancelable = true
    event.terms.each do |term|
      if term.participations.size > 0
        cancelable = false
        destroyable = false
      end
    end

    if destroyable
      #destroy in cascade
      event.destroy
      flash[:notice] = I18n.t('events.controller.Successfully_destroyed')
      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml  { head :ok }
      end
    else
      if cancelable
        event.cancel!
        flash[:notice] = I18n.t('events.controller.Successfully_cancelled')
        respond_to do |format|
          format.html { redirect_to(root_path) }
          format.xml  { head :ok }
        end
      else
        respond_to do |format|

          @event = event

          @cancel_message = I18n.t('events.controller.cancel.Send_notification.Header', :event_name => event.name)
          if event.terms.size > 0
            @cancel_message += "\n"
          end
          event.terms.each do |term|
            @cancel_message += "\n"+ display_term_box(term.start_at, term.end_at) + "\n"
          end
          if event.terms.size > 0
            @cancel_message += "\n"
          end
          @cancel_message += I18n.t('events.controller.cancel.Send_notification.Footer')

         
          format.html
          format.xml  { head :ok }
        end
      end
    end
  end

  def cancel

    event = Event.find(params[:id])


    mail = Mail.new(:sender => current_user, :subject => I18n.t('events.controller.cancel.Send_notification.Subject'), :body => params[:message])

    event.terms.each do |term|
      term.maybe_or_sure_participants.each do |user|
        recipient = Recipient.new
        recipient.user = user
        mail.recipients << recipient
      end
    end

    if(mail.save!)
      Delayed::Job.enqueue(EmailsSenderJob.new(mail.id),2)
      #for testing purpose
      #job = EmailsSenderJob.new(mail.id)
      #job.perform
      event.cancel!
      flash[:notice] = I18n.t('events.controller.Successfully_cancelled')
      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml  { head :ok }
      end
    else
      flash[:error] = "A problem occured when creating the mailing. Please, try again or contact an admin."
      redirect_to event
    end


    #    event.cancel!
    #    flash[:notice] = I18n.t('events.controller.Successfully_cancelled')
    #    respond_to do |format|
    #      format.html { redirect_to(root_path) }
    #      format.xml  { head :ok }
    #    end
  end


  #  def share
  #
  #    @current_object = @event = Event.find(params[:id])
  #
  #    #friends = FacebookTools.get_user_friends(current_user)
  #
  #    #@users = friends.paginate :per_page => ENV['PER_PAGE'], :page => params[:page]
  #
  #    @users = FacebookTools.get_user_friends(current_user, params[:search])
  #
  #    #build the pre-defined messager to send
  #    @message_body = "#{get_user_name_or_pseudo(current_user)} would like to inform you about an event.\n\n"
  #    @message_body += "-------------------------\n\n"
  #    @message_body += @event.name + "\n\n"
  #    @message_body += @event.description_short + "\n\n"
  #    if @event.terms.size > 1
  #      @message_body += "Date(s):\n"
  #    elsif @event.terms.size == 1
  #      @message_body += "Date:\n"
  #    end
  #    @event.terms.each do |term|
  #      @message_body += display_term_box(term.start_at, term.end_at) + "\n"
  #    end
  #    @message_body += "\nYou can find some more information on the following link:\n"
  #    @message_body += url_for(@event)
  #
  #    respond_to do |format|
  #      format.html
  #      format.xml  { render :xml => @users }
  #      format.js {
  #        render :update do |page|
  #          page.replace_html 'results', :partial => 'users_list'
  #        end
  #      }
  #    end
  #  end
  #
  #  def do_share
  #
  #    if(current_user && params[:friends_ids] && params[:subject] && params[:body])
  #
  #      mail = Mail.new(:sender => current_user, :subject => params[:subject], :body => params[:body])
  #
  #      params[:friends_ids].each do |friend_id|
  #        recipient = Recipient.new
  #        recipient.user = User.find(friend_id)
  #        mail.recipients << recipient
  #      end
  #
  #
  #      if(mail.save!)
  #        Delayed::Job.enqueue(EmailsSenderJob.new(mail.id),2)
  #        #for testing purpose
  #        #job = EmailsSenderJob.new(mail.id)
  #        #job.perform
  #        flash[:notice] = "The message is being sent to the selected people."
  #        redirect_to event_path
  #      else
  #        flash[:error] = "A problem occured when creating the mailing. Please, try again or contact an admin."
  #        redirect_to share_event_path
  #      end
  #    else
  #      flash[:error] = "Something was missing. Be sure to write a subject, a body and to select some users."
  #      redirect_to share_event_path
  #    end
  #  end

  private

  def is_facebook_user?
    not_facebook_user_redirection unless current_user && current_user.facebook_user?
  end
  
  def not_facebook_user_redirection
    flash[:error] = I18n.t('events.controller.Not_facebook_user_redirection')
    redirect_to root_path
  end

  
  def add_categories_not_to_display(event)
    #add the categories not to display in the list of categories of the event
    categories_not_to_display = Category.find_all_by_to_display(false)
    categories_not_to_display.each do |category|
      event.categories << category unless event.categories.include?(category)
    end
  end



  def create_contribution(key, subkey, role)
    if(params[key][subkey])
      params[key][subkey].each do |id|
        if id && id!=""
          #this is a bug. We souldn't obtain an id='_all' from swap_select
          #happen when we didn't select any contributor in the list. Organizer or Partner ?
          if !id.include? "_all"
            begin
              contributor = Organism.find(id)
              contribution = Contribution.new
              contribution.event_id=@event.id
              contribution.organism_id=contributor.id
              contribution.role=role
              contribution.save
            rescue
              throw Exception.new "Unable to retrieve an organism with id '#{id}' to create a contribution"
            end
          end
        end
      end
    end
  end

  def is_granted_to_create
    not_moderator_of_any_organism unless current_user && (current_user.is_admin_or_moderator_of.size>0 or params[:type] == 'user_event')
  end

  def is_granted_to_edit?
    event = Event.find(params[:id])
    not_granted_redirection unless current_user && event.is_granted_to_edit?(current_user)
  end


  def is_granted_to_view?
    event = Event.find(params[:id])
    if event.is_private
      not_member_redirection unless current_user && event.is_granted_to_view?(current_user)
    end
  end

  def not_member_redirection
    flash[:error] = I18n.t('events.controller.Private_event')
    redirect_to('/')
  end

  def not_granted_redirection
    if current_user
      flash[:error] = I18n.t('events.controller.Not_allowed_to_do_this')
      redirect_back_or_default('/')
    else
      flash[:error] = I18n.t('events.controller.Not_allowed_to_do_this_login')
      redirect_to login_path
    end

  end

  def not_moderator_of_any_organism
    if current_user
      flash[:error] = I18n.t('events.controller.Create_event_ve_to_be_admin')
      redirect_back_or_default('/')
    else
      flash[:error] = I18n.t('events.controller.Not_allowed_to_do_this_login')
      redirect_to login_path
    end

  end

end
