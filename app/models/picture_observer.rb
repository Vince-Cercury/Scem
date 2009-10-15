class PictureObserver < ActiveRecord::Observer
  def after_create(picture)
    puts "picture observer -> after_create called"
    picture.reload

    #if the picture is passive and we wanted moderation, send activation email to concerned admins and moderators
    # if we don't want moderation, only send notification email to concerned moderators
    if picture.passive?
      prep_variables(picture)
      puts "[picture-observer] picture created (passive)"

      if @moderation_state
        puts "[picture-observer] picture moderation is ON"
        puts "[picture-observer] will send email to #{@list_moderators.size} users"
        @list_moderators.each do |user|
          puts "[picture-observer] delivering email to #{user.id}"
          PictureMailer.deliver_to_moderators_creation_moderate(user, picture, @controller) if user.receive_picture_notification unless user.email.nil?# && user != @user_creator
        end
      else
#        puts "[picture-observer] picture moderation is off"
#        @list_moderators.each do |user|
#          puts "[picture-observer] deliver email to user (moderator) with id=#{user.id}"
#          PictureMailer.deliver_to_moderators_creation_notification(user, picture, @controller) if user.receive_picture_notification# && user != @user_creator
#        end
#        @list_sys_moderators.each do |user|
#          puts "[picture-observer] deliver email to user (system moderator) with id=#{user.id}"
#          PictureMailer.deliver_to_sys_moderators_creation_notification(user, picture, @controller) if user.receive_picture_notification# && user != @user_creator
#        end
      end
    end
  end

  def after_save(picture)
    puts "[picture-observer] after_save called"

    picture.reload
    prep_variables(picture)
    

    if @moderation_state
      puts "[picture-observer] picture moderation is ON"
      if picture.recently_activated? 
        puts "[picture-observer] picture recently activated"
        #send a notification that the picture has been accepted to the author of the picture
        PictureMailer.deliver_to_author_accepted_notification(@user_creator, picture, @controller) unless user.email.nil?
        
        @list_sys_moderators.each do |user|
          puts "[picture-observer] deliver email to user (system moderator) with id=#{user.id}"
          PictureMailer.deliver_to_sys_moderators_accepted_notification(user, picture, @controller) if user.receive_picture_notification && user != @user_creator  unless user.email.nil?
        end
      end
    else
      puts "[picture-observer] picture moderation is OFF"
      if picture.recently_activated?
        puts "[picture-observer] recently activated"
        @list_moderators.each do |user|
          puts "[picture-observer] delivering email to #{user.id}"
          PictureMailer.deliver_to_moderators_creation_notification(user, picture, @controller) if user.receive_picture_notification unless user.email.nil?# && user != @user_creator
        end
        @list_sys_moderators.each do |user|
          puts "[picture-observer] deliver email to user (system moderator) with id=#{user.id}"
          PictureMailer.deliver_to_sys_moderators_creation_notification(user, picture, @controller) if user.receive_picture_notification unless user.email.nil?# && user != @user_creator
        end
      end

    end

    #send an email to sys moderators in case picture was suspended!
    if picture.recently_suspended?
      puts "[picture-observer] picture recently suspended"
      @list_sys_moderators.each do |user|
        puts "[picture-observer] deliver email to user (system moderator) with id=#{user.id}"
        PictureMailer.deliver_to_sys_moderators_suspended_notification(user, picture, @controller) if user.receive_picture_notification && user != @user_creator unless user.email.nil?
      end
    end

  end


  private



  def prep_variables(picture)
    puts "[picture-observer] preparate useful variables and lists"
    
    @user_creator = User.find(picture.creator_id)

    #get the object on which a picture has been posted
    @picturable_object = Picture.find_parent(picture.parent_type, picture.parent_id)


    @list_moderators = @picturable_object.get_moderators_list

    @list_sys_moderators = get_list_sys_admins_or_modo

    #for every type of pictureable, find moderators for notifiying
    case picture.parent_type
    when "Event"
      @controller = "events"
    when "Organism"
      @controller = "organisms"
    when "Gallery"
      @controller = "galleries"
      @moderation_state=@picturable_object.add_picture_moderation
    else
      @controller = "unknow"
    end
    

    #defining if the moderation is activated
    #if the author of the picture is a moderator or the organism (publisher)
    #or a system moderator, the moderation is neceserally off
    if @picturable_object.is_user_moderator?(@user_creator)
      @moderation_state = false
    end

  end



  def get_list_sys_admins_or_modo
    list_sys_moderators = Array.new 
    #for each system_moderator and system_admin, send signup notification email (contening picture infos)
    system_admins_or_modo = User.find(:all, :conditions => ["role = ? or role = ?", "admin", "moderator"] )
    system_admins_or_modo.each  do |user|
      #if !@list_recipients.include?(user)
      list_sys_moderators << user
      #end
    end
    return  list_sys_moderators
  end
end

