class PicturesController < ApplicationController

  before_filter :ensure_activated, :only => [:show]
  before_filter :ensure_create_rights?, :only => [:new, :create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update, :suspend]
  before_filter :ensure_has_current_user_moderation_rights, :only => [:activate, :unsuspend]

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  before_filter :ensure_parameters, :only=>[:new, :create]



  # GET /pictures
  # GET /pictures.xml
  def index
    @pictures = Picture.paginate :per_page => ENV['PER_PAGE'], :page => params[:page],
      :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pictures }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'pictures_list'
        end
      }
    end
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @current_object = @picture = Picture.find(params[:id])

    #the object comment is needed for displaying the form of new comment
    initialize_new_comment(@picture)

    @parent_object = @picture.get_parent_object

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  # GET /pictures/new
  # GET /pictures/new.xml
  def new
    @picture = Picture.new

    if(params[:organism_id])
      @parent_object = Organism.find(params[:organism_id])
      @picture.parent_id = params[:organism_id]
      @picture.parent_type = 'Organism'
    end

    if(params[:event_id])
      @parent_object = Event.find(params[:event_id])
      @picture.parent_id = params[:event_id]
      @picture.parent_type = 'Event'
    end
    
    if(params[:user_id])
      @parent_object = User.find(params[:user_id])
      @picture.parent_id = params[:user_id]
      @picture.parent_type = 'User'
    end
    
    wrong_parameters_redirection unless @parent_object

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  # POST /pictures
  # POST /pictures.xml
  def create
    @picture = Picture.new(params[:picture])
    @picture.creator_id = current_user.id
    @picture.parent_type = params[:parent_type]
    @picture.parent_id = params[:parent_id]

    parent_object = Picture.find_parent(params[:parent_type], params[:parent_id])

   # raise Picture.get_picture_root_path(params[:parent_type], params[:parent_id]).inspect

    if !parent_object.picture.nil? 
      if !parent_object.picture.suspended?
        parent_object.picture.suspend!
      end
    end


    respond_to do |format|
      if @picture.save
        
        @picture.activate! unless @picture.parent_type=="Gallery" && parent_object.add_picture_moderation


        flash[:notice] = 'Picture has been successfully created.'
        format.html { redirect_to(url_for_even_polymorphic(@picture)) }
        format.xml  { render :xml => parent_object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pictures/1
  # PUT /pictures/1.xml
  def update
    
    @picture = Picture.find(params[:id])


    respond_to do |format|
      if @picture.update_attributes(params[:picture])

        flash[:notice] = 'Picture has been successfully updated.'
        format.html { redirect_to(url_for_even_polymorphic(@picture)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    picture = Picture.find(params[:id])
    picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)
    if picture.nil?
      flash[:error] = "We couldn't find the picture."
      redirect_back_or_default('/')
    else
      picture.activated_by = current_user.id
      picture.activate!
      flash[:notice]  = "Ok, picture activated"
      redirect_to(picturable_object)
    end
  end

  # PUT /users/1/suspend
  def suspend
    picture = Picture.find(params[:id])
    picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)
    picture.suspended_by = self.current_user.id
    picture.suspend!
    flash[:notice] = 'Picture has been suspended.'
    redirect_to(url_for_even_polymorphic(picturable_object))
  end

  # PUT /users/1/unsuspend
  def unsuspend
    picture = Picture.find(params[:id])
    picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)
    picture.unsuspend!
    flash[:notice] = 'Picture has been unsuspended.'
    redirect_to(picturable_object)
  end

  private

  def ensure_activated
    picture = Picture.find(params[:id])
    not_visible unless (picture && picture.active?) or has_current_user_moderation_rights
  end

  def has_current_user_moderation_rights
    picture = Picture.find(params[:id])
    picture && self.current_user && (picture.is_user_moderator?(current_user) or self.current_user.has_system_role('moderator'))
  end

  def ensure_moderator_edit_rights?
    puts "ensure current user is owner or has moderation rights (picture)"
    picture = Picture.find(params[:id])
    not_enough_rights unless self.current_user && picture && picture.creator_id==self.current_user.id or has_current_user_moderation_rights
  end

  def ensure_create_rights?
    parent_object = Picture.find_parent(params[:parent_type], params[:parent_id]) if params[:parent_type] && params[:parent_id]
    not_enough_rights unless self.current_user && ((parent_object && parent_object.is_user_moderator?(self.current_user)) or self.current_user.has_system_role('moderator') or (parent_object.type=="Gallery" && parent_object.is_user_allowed_add_picture(self.current_user)))
  end

  def ensure_parameters
    wrong_parameters_redirection unless (params[:organism_id] or params[:event_id] or params[:user_id])
  end

  def ensure_has_current_user_moderation_rights
    puts "ensure has current user moderation rights (comment)"
    not_enough_rights unless has_current_user_moderation_rights
  end

  def not_enough_rights
    flash[:error] = "Not allowed to do this. Not owner or enough rights."
    redirect_to root_path
  end


  def wrong_parameters_redirection
    flash[:error] = "Some parameters are missing or wrong"
    redirect_to root_path
  end

  def not_visible
    flash[:error] = "Sorry, the picture is not visible"
    redirect_to root_path
  end
  
end
