class PicturesController < ApplicationController

  before_filter :ensure_activated, :only => [:show]
  before_filter :ensure_create_rights?, :only => [:new, :create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update, :suspend]
  before_filter :ensure_has_current_user_moderation_rights, :only => [:activate, :unsuspend]

  # logged in mandatory to view a picture full size
  before_filter :is_logged?, :only => [:show]

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]




  # GET /pictures
  # GET /pictures.xml
  def index
#    @pictures = Picture.paginate :per_page => ENV['PER_PAGE'], :page => params[:page],
#      :order => 'created_at DESC'
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @pictures }
#      format.js {
#        render :update do |page|
#          page.replace_html 'results', :partial => 'pictures_list'
#        end
#      }
#    end
    flash[:error] = "Wrong url. Please contact admin if problem persists..."
    redirect_to root_path
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @current_object = @picture = Picture.find(params[:id])

    #the object comment is needed for displaying the form of new comment
    initialize_new_comment(@picture)

    @comments = @picture.comments

    @parent_object = @picture.get_parent_object

    if @picture.parent_type == 'Gallery'
      @header_gallery  = '/galleries/header'
      @gallery = @parent_object
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @picture }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'picture_show'
        end
      }
    end
  end

  # GET /pictures/new
  # GET /pictures/new.xml
  def new
    @picture = Picture.new


    ensure_parent_parameters
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])

    @parent_object = @picture.get_parent_object

    if @picture.parent_type == 'Gallery'
      @header_gallery  = '/galleries/header'
      @gallery = @parent_object
    end
  end

  # POST /pictures
  # POST /pictures.xml
  def create
    @picture = Picture.new(params[:picture])
    @picture.creator_id = current_user.id

    ensure_parent_parameters

    # raise Picture.get_picture_root_path(params[:parent_type], params[:parent_id]).inspect

    if !@parent_object.picture.nil?
      if !@parent_object.picture.suspended?
        @parent_object.picture.suspend!
      end
    end


    respond_to do |format|
      if @picture.save
        
        @picture.activate! unless @picture.parent_type=="Gallery" && @parent_object.add_picture_moderation


        flash[:notice] = I18n.t('pictures.controller.Successfully_created')
        format.html { redirect_to(url_for_even_polymorphic(@parent_object)) }
        format.xml  { render :xml => @parent_object }
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

        flash[:notice] = I18n.t('pictures.controller.Successfully_updated')
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
      flash[:error] =  I18n.t('pictures.controller.Cant_find_picture')
      redirect_back_or_default('/')
    else
      picture.activated_by = current_user.id
      picture.activate!
      flash[:notice]  = I18n.t('pictures.controller.Activated')
      redirect_to(picturable_object)
    end
  end

  # PUT /users/1/suspend
  def suspend
    picture = Picture.find(params[:id])
    picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)
    picture.suspended_by = self.current_user.id
    picture.suspend!
    flash[:notice] = I18n.t('pictures.controller.Suspended')
    redirect_to(url_for_even_polymorphic(picturable_object))
  end

  # PUT /users/1/unsuspend
  def unsuspend
    picture = Picture.find(params[:id])
    picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)
    picture.unsuspend!
    flash[:notice] = I18n.t('pictures.controller.Activated')
    redirect_to(picturable_object)
  end

  private

  def ensure_parent_parameters

    wrong_parameters_redirection unless (params[:organism_id] or params[:event_id] or params[:user_id])

    if(params[:organism_id])
      @parent_object = Organism.find(params[:organism_id])
      @picture.parent_id = @parent_object.id
      @picture.parent_type = 'Organism'
    end

    if(params[:event_id])
      @parent_object = Event.find(params[:event_id])
      @picture.parent_id = @parent_object.id
      @picture.parent_type = 'Event'
    end

    if(params[:user_id])
      @parent_object = User.find(params[:user_id])
      @picture.parent_id = @parent_object.id
      @picture.parent_type = 'User'
    end

    wrong_parameters_redirection unless @parent_object
  end

  def get_parent_object_from_params
    
    if(params[:organism_id])
      parent_object = Organism.find(params[:organism_id])
    end

    if(params[:event_id])
      parent_object = Event.find(params[:event_id])
    end

    if(params[:user_id])
      parent_object = User.find(params[:user_id])
    end

    wrong_parameters_redirection unless parent_object

    return parent_object
  end

  def ensure_activated
    picture = Picture.find(params[:id])
    not_visible unless (picture && picture.active?) or has_current_user_moderation_rights
  end

  def has_current_user_moderation_rights
    picture = Picture.find(params[:id])
    picture && self.current_user && (picture.is_user_moderator?(current_user) or self.current_user.has_system_role('moderator'))
  end

  def ensure_moderator_edit_rights?
    #puts "ensure current user is owner or has moderation rights (picture)"
    picture = Picture.find(params[:id])
    not_enough_rights unless self.current_user && picture && picture.creator_id==self.current_user.id or has_current_user_moderation_rights
  end

  def ensure_create_rights?
    parent_object = get_parent_object_from_params
    if parent_object
      not_enough_rights unless current_user && ((parent_object.is_user_moderator?(current_user)) or current_user.has_system_role('moderator') or (parent_object.type=="Gallery" && parent_object.is_user_allowed_add_picture(current_user)))
    end
  end

  def ensure_has_current_user_moderation_rights
    #puts "ensure has current user moderation rights (comment)"
    not_enough_rights unless has_current_user_moderation_rights
  end

  def not_enough_rights
    flash[:error] = I18n.t('pictures.controller.Not_allowed_to_do_this')
    redirect_to root_path
  end


  def wrong_parameters_redirection
    flash[:error] = I18n.t('pictures.controller.Missing_parameters')
    redirect_to root_path
  end

  def not_visible
    flash[:error] =  I18n.t('pictures.controller.Not_visible')
    redirect_to root_path
  end
  
end
