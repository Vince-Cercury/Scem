class CommentsController < ApplicationController

  before_filter :is_logged?, :only => [:create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update]
  before_filter :not_too_late_edit_comment?, :only => [:edit, :update]
  before_filter :ensure_has_current_user_moderation_rights, :only => [:activate, :suspend, :unsuspend]


  # POST /comments
  # POST /comments.xml
  def create
    puts "intend to create a comment"
    comment = Comment.new(params[:comment])
    commentable_object = Comment.find_commentable(params[:commentable_type], params[:commentable_id])

    comment.user_id = current_user.id
    #raise commentable_object.inspect
    
    respond_to do |format|
      if commentable_object.comments << comment

        #moderation depends on configuration and if the author is a moderator
        user_creator = User.find(comment.user_id)
        list_moderators = commentable_object.get_moderators_list
        if ENV['MODERATE_COMMENTS']=='true'
          moderation_state = true
        else
          moderation_state = false
        end
        if list_moderators.include?(user_creator)
          moderation_state = false
        end

        #activate the comment or not regarding to moderation state
        if moderation_state
          flash[:notice] = 'Comment created. A moderator will eventually accept it'
        else
          comment.activate!
          flash[:notice] = 'Comment was successfully added.'
        end
         
        format.html { redirect_to(commentable_object) }
        format.xml  { render :xml => commentable_object, :status => :created, :location => commentable_object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => commentable_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
		respond_to do |format|
			format.html
			format.xml { render :xml => @comment }
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    
    respond_to do |format|
			if @comment.update_attributes(params[:comment])
        
        @comment.edited_by = current_user.id
        @comment.edit!

        commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
				flash[:notice] = 'Comment was successfully updated.'
				format.html { redirect_to(commentable_object) }
				format.xml  { head :ok }
			else
				flash[:error] = 'Comment update failed.'
				format.html { render :action => "edit" }
				format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
			end
		end
  end

  def activate
    comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(comment.commentable_type, comment.commentable_id)
    if comment.nil?
      flash[:error] = "We couldn't find the comment."
      redirect_back_or_default('/')
    else
      comment.activated_by = current_user.id
      comment.activate!
      flash[:notice]  = "Ok, comment activated"
      redirect_to(commentable_object)
    end
  end

  # PUT /users/1/suspend
  def suspend
    @comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
    @comment.suspended_by = current_user.id
    @comment.suspend!
    flash[:notice] = 'Comment was suspended.'
    redirect_to(commentable_object)
  end

  # PUT /users/1/unsuspend
  def unsuspend
    @comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
    @comment.unsuspend!
    flash[:notice] = 'Comment was unsuspended.'
    redirect_to(commentable_object)
  end

  private

  def has_current_user_moderation_rights
    comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(comment.commentable_type, comment.commentable_id)

    comment && self.current_user && (commentable_object.is_user_moderator?(self.current_user) or self.current_user.has_system_role('moderator'))
  end

  def not_too_late_edit_comment?
    puts "ensure current user has moderation rights or not owner and not too late (comment)"
    comment = Comment.find(params[:id])
    too_late_editing unless comment && ((time_diff_in_minutes(comment.created_at) < Integer(ENV['TIME_ALLOW_EDIT_COMMENT']) or has_current_user_moderation_rights))
  end

  def ensure_moderator_edit_rights?
    puts "ensure current user is owner or has moderation rights (comment)"
    comment = Comment.find(params[:id])
    not_enough_rights unless self.current_user && comment && comment.user_id==self.current_user.id or has_current_user_moderation_rights
  end

  def ensure_has_current_user_moderation_rights
    puts "ensure has current user moderation rights (comment)"
    not_enough_rights unless has_current_user_moderation_rights
  end
  
  def not_enough_rights
    flash[:error] = "Not allowed to do this. Not owner or enough rights to edit the comment"
    redirect_to root_path
  end

  def too_late_editing
    flash[:error] = "Not allowed to do this. Too late for editing: #{ENV['TIME_ALLOW_EDIT_COMMENT']} minutes maximum"
    redirect_to root_path
  end

end
