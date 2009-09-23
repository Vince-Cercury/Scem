class PostsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  before_filter :ensure_moderator_create_rights?, :only => [:new, :create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update, :destroy]

  # GET /posts
  # GET /posts.xml
  def index
    
    prepare_parent_context_from_params

    if current_user && @parent_object.is_user_moderator?(current_user)
      @posts = @parent_object.search_posts(params[:search], params[:page])
    else
      @posts = @parent_object.search_posts_by_state(params[:search], params[:page], 'active')
    end
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @current_object = @post = Post.find(params[:id])
    @parent_object = @post.get_parent_object

    if(@post.active?) or (current_user && @parent_object.is_user_moderator?(current_user))
      @comment = Comment.new

      prepare_parent_context_from_parent_object(@parent_object)

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @post }
      end
    else
      flash[:notice]  = "The post is not visible"
      redirect_to(polymorphic_path([@parent_object, :posts].flatten))
    end

  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    prepare_parent_context_from_params


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit

    @post = Post.find(params[:id])
    @parent_object = @post.get_parent_object

    prepare_parent_context_from_parent_object(@parent_object)

  end

  # POST /posts
  # POST /posts.xml
  def create
    
    @post = Post.new(params[:post])
    @post.creator_id = current_user.id
    @parent_object = Post.find_parent(params[:parent_type], params[:parent_id])

    prepare_parent_context_from_parent_object(@parent_object)

    respond_to do |format|
      if @parent_object.posts << @post
        @post.activate!
        
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(url_for(polymorphic_path([@parent_object, @post].flatten))) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    parent_object = @post.get_parent_object
    prepare_parent_context_from_parent_object(parent_object)

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html {  redirect_to(url_for(polymorphic_path([parent_object, @post].flatten)))  }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    parent_object = @post.get_parent_object
    @post.destroy

    respond_to do |format|
      format.html { redirect_to( redirect_to(url_for(polymorphic_path([parent_object, :posts].flatten))) ) }
      format.xml  { head :ok }
    end
  end

  def activate
    post = Post.find(params[:id])
    parent_object = post.get_parent_object
    if post.nil?
      flash[:error] = "We couldn't find the post."
      redirect_back_or_default('/')
    else
      post.activated_by = current_user.id
      post.activate!
      flash[:notice]  = "Ok, post activated"
      redirect_to(polymorphic_path([parent_object, post].flatten))
    end
  end

  # PUT /users/1/suspend
  def suspend
    post = Post.find(params[:id])
    parent_object = post.get_parent_object
    post.suspended_by = self.current_user.id
    post.suspend!
    flash[:notice] = 'Post has been suspended.'
    redirect_to( redirect_to(polymorphic_path([parent_object, :posts].flatten)))
  end

  # PUT /users/1/unsuspend
  def unsuspend
    post = Post.find(params[:id])
    parent_object = post.get_parent_object
    post.unsuspend!
    flash[:notice] = 'Post has been unsuspended.'
    redirect_to(polymorphic_path([parent_object, post].flatten))
  end

  private

  def url_for_post_in_context(parent_object, post)
    if parent_object.
        organism_post_path(:organism_id => params[:organism_id], :id => post.id)
    end
    if params[:user_id]
      organism_post_path(:user_id => params[:user_id], :id => post.id)
    end
  end

  def parent_posts_url
    if params[:organism_id]
      organism_posts_path
    end
    if params[:user_id]
      user_posts_path
    end
  end

  def prepare_parent_context_from_parent_object(parent_object)
    
    if parent_object.class.to_s.eql?('Organism')
      @organism = parent_object
      @header_partial = 'organisms/header'
    end

    if parent_object.class.to_s.eql?('User')
      @user = parent_object
      @header_partial = 'users/header'
    end
    if parent_object.class.to_s.eql?('Event')
      @event = parent_object
      @header_partial = 'events/header'
    end
    if parent_object
      set_session_parent_pictures_root_path(parent_object)
    end
  end


  def prepare_parent_context_from_params
    if params[:organism_id]
      @organism = @parent_object = Organism.find(params[:organism_id])
      @header_partial = 'organisms/header'
    end

    if params[:user_id]
      @user = @parent_object = User.find(params[:user_id])
      @header_partial = 'users/header'
    end

    if params[:event_id]
      @event = @parent_object = Event.find(params[:event_id])
      @header_partial = 'events/header'
    end
    if @parent_object
      set_session_parent_pictures_root_path(@parent_object)
    end
      
  end

  def ensure_moderator_create_rights?
    if params[:organism_id]
      parent_type = 'Organism'
      parent_id = params[:organism_id]
    end
    if params[:user_id]
      parent_type = 'User'
      parent_id = params[:user_id]
    end
    if params[:event_id]
      parent_type = 'Event'
      parent_id = params[:event_id]
    end
    parent_object = Post.find_parent(parent_type, parent_id)
    not_enough_rights unless self.current_user && ((parent_object && parent_object.is_user_moderator?(self.current_user)) or self.current_user.has_system_role('moderator'))
  end

  def ensure_moderator_edit_rights?
    post = Post.find(params[:id])
    not_enough_rights unless self.current_user && post && (post.get_parent_object.is_user_moderator?(self.current_user) or self.current_user.has_system_role('moderator'))
  end

  def not_enough_rights
    flash[:error] = "Not allowed to do this. Not owner or enough rights."
    redirect_to root_path
  end

end
