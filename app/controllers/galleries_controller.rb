class GalleriesController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]
  before_filter :ensure_parameters, :only=>[:new, :create]

  before_filter :ensure_add_pics_rights, :only => [:edit_pics, :add_pics, :do_add_pics]
  before_filter :ensure_create_rights?, :only => [:new, :create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update, :move_a_pic]
  before_filter :ensure_has_current_user_moderation_rights, :only => [:activate, :suspend, :unsuspend]

  # GET /galleries
  # GET /galleries.xml
  def index

    if params[:organism_id]
      @parent_object = @organism = Organism.find(params[:organism_id])
      @galleries = @organism.search_galleries(params[:search], params[:page])
      @search_galleries_header = 'galleries_organism_search'
    end

    if params[:event_id]
      @parent_object = @event = Event.find(params[:event_id])
      @galleries = @event.search_galleries(params[:search], params[:page])
      @search_galleries_header = 'galleries_event_search'
    end

    if !params[:organism_id] && ! params[:event_id]
      @galleries = Gallery.search(params[:search], params[:page])
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @galleries }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'galleries_list'
        end
      }
    end
  end

  # GET /galleries/1
  # GET /galleries/1.xml
  def show
    @current_object = @gallery = Gallery.find(params[:id])
    @comments = @gallery.search_comments(params[:search], params[:page], ENV['PER_PAGE'])
    
    @parent_object = @gallery.get_parent_object

    #the object comment is needed for displaying the form of new comment
    initialize_new_comment(@gallery)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /galleries/new
  # GET /galleries/new.xml
  def new
    @gallery = Gallery.new
    @rights = {'Moderators' => 'moderators', 'Members' => 'members', 'Anybody' => 'all'}

    @gallery.parent_type = params[:parent_type]
    @gallery.parent_id = params[:parent_id]
    set_session_parent_pictures_root_path(@gallery.get_parent_object)

    @new_pictures = Array.new
    1.upto(3) { @new_pictures << Picture.new }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /galleries/1/edit
  def edit
    @gallery = Gallery.find(params[:id])

    @rights = {'Moderators' => 'moderators', 'Members' => 'members', 'Anybody' => 'all'}
    @parent_object = @gallery.get_parent_object
    set_session_parent_pictures_root_path(@gallery.get_parent_object)

  end

  # GET /galleries/1/add_pics
  def add_pics
    @gallery = Gallery.find(params[:id])
    @new_pictures = Array.new
    1.upto(3) { @new_pictures << Picture.new }
    @parent_object = Gallery.find_parent(@gallery.parent_type, @gallery.parent_id)

    respond_to do |format|
      format.html { render :action => "add_pictures" }
      format.xml  { render :xml => @gallery }
    end
  end

  def set_cover
    @gallery = Gallery.find(params[:id])
    picture = Picture.find(params[:picture_id])

    @gallery.pictures.each do |picture_|
      picture_.cover=false
      picture_.save
    end
    picture.cover = true
    picture.save

    respond_to do |format|
      if @gallery && picture && picture.save
        flash[:notice] =  I18n.t('galleries.controller.Set_cover_success')
      else
        flash[:error] = I18n.t('galleries.controller.Set_cover_fail')
      end
      format.html { redirect_to(url_for_even_polymorphic(@gallery, :action => 'edit_pics')) }
      format.xml  { render :xml => @gallery }
    end
  end


  # GET /galleries/1/edit_pics
  def edit_pics
    @gallery = Gallery.find(params[:id])
    @parent_object = Gallery.find_parent(@gallery.parent_type, @gallery.parent_id)
    

    respond_to do |format|
      format.html { render :action => "edit_pictures" }
      format.xml  { render :xml => @gallery }
    end
  end

  # PUT /galleries/1
  # PUT /galleries/1.xml
  def do_add_pics
    @gallery = Gallery.find(params[:id])
    @parent_object = Gallery.find_parent(@gallery.parent_type, @gallery.parent_id)

    prepare_pictures_attributes(@gallery)


    moderation_state=@gallery.add_picture_moderation
    if @gallery.is_user_moderator?(current_user)
      moderation_state = false
    end


    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        if(moderation_state)
          flash[:notice] = I18n.t('galleries.controller.Aprobation_required')
          format.html { redirect_to(url_for_even_polymorphic(@gallery)) }
        else
          flash[:notice] = I18n.t('galleries.controller.Add_picture_success')
          format.html { redirect_to(url_for_even_polymorphic(@gallery, :action => 'edit_pics')) }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "add_pictures" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  def move_a_pic
    @gallery = Gallery.find(params[:id])
    picture = Picture.find(params[:picture_id])
    
    result=false
    if(params[:direction] == 'up')
      picture.move_up!
      result=true
    end
    if(params[:direction] == 'down')
      picture.move_down!
      result=true
    end

    @gallery.pictures.reload

    respond_to do |format|
      if @gallery && picture && result
        flash[:notice] = I18n.t('galleries.controller.Pictures_moved_successfully')
      else
        flash[:error] = I18n.t('galleries.controller.Pictures_moved_failed')
      end
      format.html { redirect_to(url_for_even_polymorphic(@gallery, :action => 'edit_pics')) }
      format.xml  { render :xml => @gallery }
    end
  end


  # POST /galleries
  # POST /galleries.xml
  def create
    @gallery = Gallery.new(params[:gallery])
    @rights = {'Moderators' => 'moderators', 'Members' => 'members', 'Anybody' => 'all'}


    @gallery.creator_id = self.current_user.id
    @gallery.parent_id = params[:parent_id]
    @gallery.parent_type = params[:parent_type]
    @parent_object = Gallery.find_parent(params[:parent_type], params[:parent_id])
    set_session_parent_pictures_root_path(@gallery.get_parent_object)

    #prepare_pictures_attributes(@gallery)

    respond_to do |format|
      if @picture.activate!

        flash[:notice] = I18n.t('galleries.controller.Gallery_successfully_created')
        #format.html { redirect_to(@gallery) }
        format.html { redirect_to(url_for_even_polymorphic(@gallery, :action => 'add_pics')) }
        format.xml  { render :xml => @gallery}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /galleries/1
  # PUT /galleries/1.xml
  def update
    @gallery = Gallery.find(params[:id])
    @parent_object = @gallery.get_parent_object
    set_session_parent_pictures_root_path(@gallery.get_parent_object)
    @rights = {'Moderators' => 'moderators', 'Members' => 'members', 'Anybody' => 'all'}

    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])

        flash[:notice] = I18n.t('galleries.controller.Gallery_successfully_updated')
        format.html { redirect_to(url_for_even_polymorphic(@gallery)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  # DELETE /galleries/1
  # DELETE /galleries/1.xml
  def destroy

    destroyable = true

    gallery = Gallery.find(params[:id])
    parent_object = gallery.get_parent_object


    if(gallery.pictures.size>0)
      destroyable = false
    end

    if gallery.comments.size>0
      destroyable = false
    end



    if destroyable
      gallery.destroy
    else
      gallery.pictures.each do |picture|
        picture.suspend!
      end
      gallery.suspend!
    end

    respond_to do |format|
      flash[:notice] = I18n.t('galleries.controller.Successfully_destroyed')
      format.html { redirect_to(url_for_even_polymorphic(parent_object)) }
      format.xml  { head :ok }
    end
  end

  private

  def prepare_pictures_attributes(gallery)
    #add some information to attributes of each new picture
    pictures_attributes = params[:gallery][:picture_attributes]


    #pictures are ordered within a gallery by using an order attribute
    #we gat the last maximum, and incrmeent it for each new picture
    #    if gallery.pictures.size > 0
    #      last_order_number= gallery.get_last_order_value
    #    else
    #      last_order_number = 0
    #    end



    if !pictures_attributes.nil?
      pictures_attributes.each do |picture_attributes|
        #last_order_number += 1
        picture_attributes[:creator_id] = self.current_user.id
        picture_attributes[:parent_id] = gallery.id unless gallery.id.nil?
        picture_attributes[:parent_type] = 'Gallery'
        
        #picture_attributes[:order] = last_order_number
        

        #if moderation is off or current user is a moderator, process activation of the picture
        if !gallery.add_picture_moderation or gallery.is_user_moderator?(self.current_user)
          picture_attributes[:state] = "active"
        end

      end
    else
      raise pictures_attributes.inspect
    end
  end

  def has_current_user_moderation_rights
    gallery = Gallery.find(params[:id])
    gallery && self.current_user && (gallery.is_user_moderator?(self.current_user) or self.current_user.has_system_role('moderator'))
  end

  def ensure_create_rights?
    parent_object = Gallery.find_parent(params[:parent_type], params[:parent_id])
    not_enough_rights unless self.current_user && ((parent_object && parent_object.is_user_moderator?(self.current_user)) or self.current_user.has_system_role('moderator'))
  end

  def ensure_moderator_edit_rights?
    # puts "ensure current user is owner or has moderation rights (picture)"
    gallery = Gallery.find(params[:id])
    not_enough_rights unless self.current_user && gallery && gallery.creator_id==self.current_user.id or has_current_user_moderation_rights
  end

  def ensure_parameters
    wrong_parameters_redirection unless params[:parent_type] && params[:parent_id] && Picture.find_parent(params[:parent_type], params[:parent_id])
  end

  def ensure_add_pics_rights
    right_ok=false
    gallery = Gallery.find(params[:id])
    case gallery.add_picture_right
    when 'members'
      if self.current_user && gallery.is_user_parents_member?(self.current_user)
        right_ok=true
      end
    when 'all'
      if self.current_user
        right_ok=true
      end
    else
      if has_current_user_moderation_rights
        right_ok=true
      end
    end
    not_enough_rights unless right_ok
  end

  def wrong_parameters_redirection
    flash[:error] = I18n.t('galleries.controller.Gallery_successfully_updated')
    redirect_to root_path
  end


  def not_enough_rights
    flash[:error] =  I18n.t('galleries.controller.Missing_parameters')
    redirect_to root_path
  end


end
