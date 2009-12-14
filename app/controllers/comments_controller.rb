class CommentsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index]
  before_filter :is_logged?, :only => [:create]
  before_filter :ensure_moderator_edit_rights?, :only => [:edit, :update]
  before_filter :not_too_late_edit_comment?, :only => [:edit, :update]
  before_filter :ensure_has_current_user_moderation_rights, :only => [:activate, :suspend, :unsuspend]


  def index
    
    if params[:organism_id]
      @current_object = @organism = Organism.find(params[:organism_id])
      @comments = @organism.search_comments(params[:search], params[:page], ENV['PER_PAGE'])
      @search_comments_header = 'comments_organism_search'
      initialize_new_comment(@organism)
    end

    if params[:event_id]
      @current_object = @event = Event.find(params[:event_id])
      @comments = @event.search_comments(params[:search], params[:page], ENV['PER_PAGE'])
      @search_comments_header = 'comments_event_search'
      initialize_new_comment(@event)
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'list'
        end
      }
    end
  end

  # POST /comments
  # POST /comments.xml
  def create
    #puts "intend to create a comment"
    @comment = Comment.new(params[:comment])
    @current_object = commentable_object = Comment.find_commentable(params[:commentable_type], params[:commentable_id])

    @comment.user_id = current_user.id
    #raise commentable_object.inspect

    result = false
    #respond_to do |format|
    if @comment.valid? && commentable_object.comments << @comment

      result = true
      #moderation depends on configuration and if the author is a moderator
      user_creator = User.find(@comment.user_id)
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
        #flash[:notice] = 'Comment created. A moderator will eventually accept it'
      else
        @comment.activate!
        #flash[:notice] = 'Comment was successfully added.'
      end
    end

    respond_to do |format|
      if result
        format.js {
          render :update do |page|
            page.replace_html 'create-comment-form', :partial => 'comment', :locals => {:comment => @comment}
          end
        }
      else
        format.js {
          render :update do |page|
            #        render :update do |page|
            page.replace_html "create-form-content", :partial => 'create_form', :locals => {:comment => @comment}
            #        end
          end
        }
  
      end
    end
    #inserting html


    # redirect_back_or_default('/')
    #format.html { redirect_to(url_for_even_polymorphic(commentable_object)) }
    #format.xml  { render :xml => commentable_object, :status => :created, :location => commentable_object }
    #      else
    #        format.html { render :action => "new" }
    #        format.xml  { render :xml => cosmmentable_object.errors, :status => :unprocessable_entity }
    #      end
    #end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:comment_id])
		respond_to do |format|
			#format.html
			#format.xml { render :xml => @comment }
      format.js {
        render :update do |page|
          page.replace_html "comment_#{@comment.id}-content", :partial => 'edit_form', :locals => {:comment => @comment}
        end
      }
    end

  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:comment_id])
    #raise params.inspect
    
    respond_to do |format|
			if @comment.valid? &&@comment.update_attributes(params[:comment])
        
        @comment.edited_by = current_user.id
        @comment.edit!

        #commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
        #				flash[:notice] = 'Comment was successfully updated.'
        #				format.html { redirect_to(commentable_object) }
        #				format.xml  { head :ok }

        format.js {
          render :update do |page|
            page.replace_html "comment_#{@comment.id}-content", :partial => 'content', :locals => {:comment => @comment}
          end
        }

			else
        format.js {
          render :update do |page|
            page.replace_html "comment_#{@comment.id}-content", :partial => 'edit_form', :locals => {:comment => @comment}
          end
        }
				#flash[:error] = 'Comment update failed.'
				#format.html { render :action => "edit" }
				#format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
			end
		end
  end

  def activate
    comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(comment.commentable_type, comment.commentable_id)
    if comment.nil?
      flash[:error] = I18n.t('comments.controller.Couldnt_find_comment')
      redirect_back_or_default('/')
    else
      comment.activated_by = current_user.id
      comment.activate!
      flash[:notice]  = I18n.t('comments.controller.Comment_activated')
      redirect_to(commentable_object)
    end
  end

  # PUT /users/1/suspend
  def suspend
    @comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
    @comment.suspended_by = current_user.id
    @comment.suspend!
    flash[:notice] = I18n.t('comments.controller.Comment_suspended')
    redirect_to(commentable_object)
  end

  # PUT /users/1/unsuspend
  def unsuspend
    @comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(@comment.commentable_type, @comment.commentable_id)
    @comment.unsuspend!
    flash[:notice] = I18n.t('comments.controller.Comment_unsuspended')
    redirect_to(commentable_object)
  end

  private

  def has_current_user_moderation_rights
    comment = Comment.find(params[:id])
    commentable_object = Comment.find_commentable(comment.commentable_type, comment.commentable_id)

    comment && self.current_user && (commentable_object.is_user_moderator?(self.current_user) or self.current_user.has_system_role('moderator'))
  end

  def not_too_late_edit_comment?
    #puts "ensure current user has moderation rights or not owner and not too late (comment)"
    comment = Comment.find(params[:comment_id])
    too_late_editing unless comment && ((time_diff_in_minutes(comment.created_at) < Integer(ENV['TIME_ALLOW_EDIT_COMMENT']) or has_current_user_moderation_rights))
  end

  def ensure_moderator_edit_rights?
    #puts "ensure current user is owner or has moderation rights (comment)"
    comment = Comment.find(params[:comment_id])
    not_enough_rights unless self.current_user && comment && comment.user_id==self.current_user.id or has_current_user_moderation_rights
  end

  def ensure_has_current_user_moderation_rights
    #puts "ensure has current user moderation rights (comment)"
    not_enough_rights unless has_current_user_moderation_rights
  end
  
  def not_enough_rights
    flash[:error] = I18n.t('comments.controller.Not_allowed_no_right')
    redirect_to root_path
  end

  def too_late_editing
    flash[:error] = I18n.t('comments.controller.Not_allowed_too_late',:minuts =>" #{ENV['TIME_ALLOW_EDIT_COMMENT']}")
    redirect_to root_path
  end

end
