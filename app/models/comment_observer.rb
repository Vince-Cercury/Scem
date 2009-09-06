class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    puts "comment observer -> after_create called"
    comment.reload

    #if the comment is passive and we wanted moderation, send activation email to concerned admins and moderators
    # if we don't want moderation, only send notification email to concerned moderators
    if comment.passive?
      puts "comment created (passive)"
      
      prep_variables(comment)
      
      if @moderation_state
        puts "comment moderation is ON"
        @list_moderators.each do |user|
          CommentMailer.deliver_to_moderators_creation_moderate(user, comment, @commentable_object) if user.receive_comment_notification
        end
      else
        puts "comment moderation is off"
        @list_moderators.each do |user|
          puts "deliver email to user (moderator) with id=#{user.id}"
          CommentMailer.deliver_to_moderators_creation_notification(user, comment, @commentable_object) if user.receive_comment_notification
        end
        @list_sys_moderators.each do |user|
          puts "deliver email to user (system moderator) with id=#{user.id}"
          CommentMailer.deliver_to_sys_moderators_creation_notification(user, comment, @commentable_object) if user.receive_comment_notification
        end
      end

    end
  end

  def after_save(comment)
    puts "comment observer -> after_save called"

    comment.reload
    prep_variables(comment)
    

    if @moderation_state
      puts "comment moderation is ON"
      if comment.recently_activated?
        puts "comment recently activated"
        #send a notification that the comment has been accepted to the author of the comment
        CommentMailer.deliver_to_author_accepted_notification(@user_creator, comment, @commentable_object)
        
        @list_sys_moderators.each do |user|
          puts "deliver email to user (system moderator) with id=#{user.id}"
          CommentMailer.deliver_to_sys_moderators_accepted_notification(user, comment, @commentable_object) if user.receive_comment_notification
        end
      end
    end

    #send an email to sys moderators in case comment was suspended!
    if comment.recently_suspended?
      puts "comment recently suspended"
      @list_sys_moderators.each do |user|
        puts "deliver email to user (system moderator) with id=#{user.id}"
        CommentMailer.deliver_to_sys_moderators_suspended_notification(user, comment, @commentable_object) if user.receive_comment_notification
      end
    end

    
  end



  private

  def prep_variables(comment)
    puts "preparate useful variables and lists"

    @user_creator = User.find(comment.user_id)

    @list_moderators = Array.new
    @list_sys_moderators = Array.new

    #get the object on which a comment has been posted
    @commentable_object = Comment.find_commentable(comment.commentable_type, comment.commentable_id)

    prep_list_sys_admins_or_modo

    @list_moderators = @commentable_object.get_moderators_list

    #defining if the moderation is activated
    #if the author of the comment is a moderator or the organism (publisher)
    #or a system moderator, the moderation is neceserally off
    if ENV['MODERATE_COMMENTS']=='true'
      @moderation_state = true
    else
      @moderation_state = false
    end
    if @list_moderators.include?(@user_creator)
      @moderation_state = false
    end

  end


  #  def investigate_parent_moderators(commentable_object)
  #    puts "try to get parent moderators"
  #    #resursively get the parent until no more parents
  #    begin
  #      parent = commentable_object.get_parent_object
  #    end while(commentable_object.get_parent_object!=nil)
  #    if(parent.class=="Event")
  #      prep_list_event_moderators(parent)
  #    end
  #    if(parent.class=="Organism")
  #      prep_list_organism_moderators(parent)
  #    end
  #  end

  #  def prep_list_event_moderators(event)
  #    event.publishers.each do |organism_publisher|
  #      prep_list_organism_moderators(organism_publisher)
  #    end
  #  end
  #
  #  def prep_list_organism_moderators(organism)
  #    #for each _organism_moderator and organism_admin, send signup notification email
  #    organism_admins_or_modo = organism.admins + organism.moderators
  #    organism_admins_or_modo.each  do |user|
  #      #if @list_recipients_parent_moderator.include?(user)
  #      @list_moderators << user
  #      #end
  #    end
  #
  #  end


  def prep_list_sys_admins_or_modo
    #for each system_moderator and system_admin, send signup notification email (contening comment infos)
    @system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    @system_admins_or_modo.each  do |user|
      #if !@list_recipients.include?(user)
      @list_sys_moderators << user
      #end
    end
  end
end

