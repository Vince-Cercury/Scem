class FacebookController < ApplicationController
   before_filter :ensure_authenticated_to_facebook
  
  # Protect these actions behind a moderator login
  before_filter :is_granted_to_edit_term?, :only => [:cancel_event, :ask_facebook_event_categories, :create_event, :ask_facebook_event_cancel_message]

   def index
    if self.current_user.nil?
      #register with fb
      User.create_from_fb_connect(facebook_session.user)

      # activate! method is not working properly, maybe because some user fiels are not valid ?
      #current_user.set_activate(true)
      current_user.state = 'active'
      current_user.activated_at = Time.now

      flash[:notice] = "Congratulations! You have registered with success thanks to your Facebook account."
    else
      #connect accounts
      self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
    end

    #TODO: check that new user in table via Facebook get state=active

    #update facebook avatar pictures, first_name, last_name
    current_user.fb_image=facebook_session.user.pic
    current_user.fb_image_small=facebook_session.user.pic_small
    
    current_user.fb_image_big=facebook_session.user.pic_big

    current_user.first_name=facebook_session.user.first_name
    current_user.last_name=facebook_session.user.last_name

    if current_user.email.include?('facebook.com')
      current_user.email = facebook_session.user.proxied_email
    end

    current_user.save(false)



    #we want to retrieve a fresh list of users friends info (first and last name, small pic)
    #from Facebook. This job is delayed as it takes a lot of time (many calls via Facebook API)
    #Delayed::Job.enqueue(FacebookRetrieveFriendsJob.new(current_user.id, facebook_session.user), 3)


    if(current_user.email.nil? or current_user.email=="" or !facebook_session.user.has_permissions?(['email','publish_stream','rsvp_event','create_event']))
      redirect_to url_for(:controller => 'users', :id => current_user.id, :action => 'ask_facebook_info')
    else
      redirect_back_or_default('/')
    end


  end

  #Send a message to friends selected users for inviting them to use this app
  #  def send_invitations
  #
  #    @user = User.find(params[:id])
  #
  #    if facebook_session && @user
  #
  #      subject = "Everything happening in your city !"
  #
  #      if facebook_session.send_email(params[:facebook_friends_uids], subject, params[:message])
  #        flash[:notice] = "The message has been sent to the selected users !"
  #      else
  #        flash[:eror] = "A problem occured when trying to send the message. You can try again later. Sorry..."
  #      end
  #      redirect_to user_other_friends_path(:user_id => @user.id, :page => params[:page])
  #    else
  #      flash[:eror] = "A problem occured when trying to send the message. You can try again later. Sorry..."
  #      redirect_to root_path
  #    end
  #  end

  #Publish object link on the wall of an user
  def publish_object_on_wall

    #which objet do we proceed ?
    if params[:event_id]
      @current_object = @event = Event.find(params[:event_id])
      @header = '/events/header'
      picture_url = ENV['SITE_URL'] + url_for(@event.picture.attached.url(:thumb))
    end
    if params[:organism_id]
      @current_object = @organism = Organism.find(params[:organism_id])
      @header = '/organisms/header'
      picture_url = ENV['SITE_URL'] + url_for(@organism.picture.attached.url(:thumb))
    end
    if params[:gallery_id]
      @current_object = @gallery = Gallery.find(params[:gallery_id])
      @header = '/galleries/header'
      picture_url = ENV['SITE_URL'] + url_for(@gallery.cover.attached.url(:thumb))
    end

    @user_recipient = User.find(params[:user_id])


    if facebook_session && @current_object && @user_recipient
      if facebook_session.user.has_permissions?('publish_stream')

        fb_recipient = Facebooker::User.new(@user_recipient.fb_user_id)

        if fb_recipient
          message = ""
          message +=  "#{@current_object.name}\n\n"
          if @gallery
            message += process_description(@current_object.description) + "\n\n"
          else
            message += process_description(@current_object.description_short) + "\n\n"
          end
          message += "#{url_for(@current_object)}\n"

          #preparing the attachment : the image of the object
          attachment = {
            :name => "#{@current_object.name}",
            :href => "#{url_for(@current_object)}",
            :media => [ {
                :type => "image",
                :src => "#{picture_url}",#'http://www.lebounce.com/system/uploads/events/8/Image/132/small.jpg?1253871376',#
                :href => "#{url_for(@current_object)}"
              }]
          }
          # raise attachment.inspect

          begin
            
            stream_id = facebook_session.user.publish_to(fb_recipient,  :message => message,
              :action_links => [
                :text => @current_object.name,
                :href => url_for(@current_object)
              ],
              :attachment => attachment
            )

          rescue
            flash[:error] = I18n.t('facebook.controller.Publish_problem')
            redirect_to @current_object
          end

          if stream_id
            flash[:notice] = I18n.t('facebook.controller.Publish_success')
            redirect_to @current_object
          end
        else
          flash[:error] = I18n.t('facebook.controller.Couldnt_find_account',:user => "#{@user_recipient.first_name} &nbsp #{@user_recipient.last_name}")
          redirect_to root_path
        end
      else
        #prompt for extended Facebook permissions
        respond_to do |format|
          format.html { render :action => "ask_publish_stream_permission_for_wall" }
          format.xml  { render :xml => @current_object }
        end
      end
    else
      flash[:error] = I18n.t('facebook.controller.Logged_request_publish')
      redirect_to root_path
    end
  end



  #following methods are about creation of events

  def ask_facebook_event_cancel_message

    @term = Term.find(params[:id])
    @current_object = @event = @term.event unless @term.nil?

    if facebook_session
      if facebook_session.user.has_permissions?('create_event')
        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml => @term }
        end
      else
        #prompt for extended Facebook permissions
        respond_to do |format|
          format.html { render :action => "ask_events_permissions_for_cancelling" }
          format.xml  { render :xml => current_user }
        end
      end
    else 
      flash[:error] = I18n.t('facebook.controller.Logged_request_cancel')
      redirect_to root_path
    end

  end


  def cancel_event
    #check if the app has the extended event permission granted by the current user
    if facebook_session
      if facebook_session.user.has_permission?('create_event')

        @term = Term.find(params[:id])
        if @term
          #raise params[:cancel_message].inspect
          facebook_session.cancel_event(@term.facebook_eid, :cancel_message => params[:cancel_message])
          @term.facebook_eid = ""
          @term.updated_at = Time.now

          if @term.save!
            #redirect to the Facebook event page 
            flash[:notice] = I18n.t('facebook.controller.Cancel_success')
            redirect_to @term.event
          else
            flash[:error] =  I18n.t('facebook.controller.Cancel_problem')
            redirect_to @term.event
          end
        else
          flash[:error] = I18n.t('facebook.controller.Event_not_found')
          redirect_to root_path
        end

      else
        @term = Term.find(params[:id])
        #prompt for extended Facebook permissions
        respond_to do |format|
          format.html { render :action => "ask_events_permissions_for_cancelling" }
          format.xml  { render :xml => current_user }
        end
      end
    else
      flash[:error] = I18n.t('facebook.controller.Logged_request_cancel')
      redirect_to root_path
    end

  end

  def ask_facebook_event_categories

    @term = Term.find(params[:id])
    @current_object = @event = @term.event unless @term.nil?

    if facebook_session
      if facebook_session.user.has_permission?('create_event')
        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml => @term }
        end
      else
        #prompt for extended Facebook permissions
        respond_to do |format|
          format.html { render :action => "ask_events_permissions_for_creation" }
          format.xml  { render :xml => current_user }
        end
      end
    else
      flash[:error] = I18n.t('facebook.controller.Logged_request_create')
      redirect_to root_path
    end

  end

  #Note: create events take a term !
  def create_event
    #check if the app has the extended event permission granted by the current user
    if facebook_session
      if facebook_session.user.has_permissions?(['create_event','rsvp_event'])

        @term = Term.find(params[:id])
        if @term

          #Prepare picture for event
          if @term.event.picture.nil?
            fullpath = RAILS_ROOT  + "/public" + '/system/uploads' + "/default/event/medium/1.jpg"
          else
            fullpath = @term.event.picture.attached.path(:medium)
          end
          
          file = File.open(fullpath,"rb")
          data = data = file.read
          mpf = Net::HTTP::MultipartPostFile.new(@term.event.picture.attached_file_name,nil,data)

          event_eid = facebook_session.create_event(facebook_event_info(@term), mpf)
          file.close
          @term.facebook_eid = event_eid
          @term.updated_at = Time.now

          if @term.save!
            #redirect to the Facebook event page
            
            flash[:notice] = I18n.t('facebook.controller.Publish_event_success')
            redirect_to @term.event
          else
            flash[:error] =  I18n.t('facebook.controller.Event_problem')
            redirect_to @term.event
          end
        else
          flash[:error] = I18n.t('facebook.controller.Event_not_found')
          redirect_to root_path
        end

      else
        @term = Term.find(params[:id])
        #prompt for extended Facebook permissions
        respond_to do |format|
          format.html { render :action => "ask_events_permissions_for_creation" }
          format.xml  { render :xml => current_user }
        end
      end
    else 
      flash[:error] = I18n.t('facebook.controller.Logged_request_create')
      redirect_to root_path
    end

  end

  def ask_events_permissions_rsvp
    @term = Term.find(params[:id])
    @current_object = @event = @term.event unless @term.nil?

    if facebook_session
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @term }
      end
    else 
      flash[:error] = I18n.t('facebook.controller.Logged_request_status')
      redirect_to root_path
    end

  end

  protected

  def facebook_event_info(term)
    event = term.event

    if term.event.is_private
      privacy_type = 'SECRET'
    else
      privacy_type = 'OPEN'
    end

    if term.event.publishers.size > 0
      location = term.event.publishers.first.name + ' (' + url_for(term.event.publishers.first) + ')'
      # city = 'Angers, France'
      # street = 'not precised'
    else
      location = 'not precised'
      #city = 'Angers, France'
      #street = 'not precised'
    end

    # Note: The start_time and end_time are the times that were input by the event creator,
    # converted to UTC after assuming that they were in Pacific time (Daylight Savings or
    # Standard, depending on the date of the event), then converted into Unix epoch time.
    # Basically this means for some reason facebook does not want to get epoch timestamps
    # here, but rather something like epoch timestamp minus 7 or 8 hours, depeding on the
    # date. have fun!
    #
    # http://wiki.developers.facebook.com/index.php/Events.create
    start_time = (term.start + 8.hours).to_i
    end_time = term.end ? (term.end + 8.hours).to_i : start_time

    {
      'name' => event.name,
      'category' => params[:category], #event.facebook_category.to_s,
      'subcategory' => params[:subcategory], #event.facebook_subcategory.to_s,
      'host' => url_for(term.event),
      'location' => location,#[event.place.title, event.place.classification].compact.join(', '),
      #'street' => street,
      #'city' => city, #event.city.to_s,
      'description' => facebook_description(event),
      'privacy_type' => privacy_type,
      'start_time' => start_time,
      'end_time' => end_time
    }
  end

  def facebook_description(event)
    text = ""

    text +=
      "Publicated by SCEM application - http://www.lebounce.com\n" +
      "Event also visible on: #{url_for(event)}" +
      "\n\n---------------------------------------------------------------------\n\n"


    text += process_description(event.description_short)

    #TODO: price, contributors, etc

    text += "\n\n---------------------------------------------------------------------\n" +
      "Publicated by SCEM application - http://www.lebounce.com\n"+
      "Event also visible on: #{url_for(event)}"
  end

  def process_description(original_description)
    original_description = original_description.gsub(/<\/?[^>]*>/, "")
    text = ""
    unless original_description.blank?
      description = original_description.gsub(/\[(.+?)\|(.+?)\]/, '\2 (\1)') # Replace named links
      description.gsub!(%r{(http://)?www.}, 'http://www.') # FB only supports http:// links
      text += "#{description}"
    end
  end

  def is_granted_to_edit_term?
    term = Term.find(params[:id])
    not_granted_redirection unless current_user && term.event.is_granted_to_edit?(current_user)
  end

  def not_granted_redirection
    flash[:error] = I18n.t('facebook.controller.Not_allowed_to_do_this')
    redirect_to root_path
  end

end
