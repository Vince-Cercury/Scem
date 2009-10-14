class FacebookController < ApplicationController
  before_filter :ensure_authenticated_to_facebook

  def index
    if self.current_user.nil?
      #register with fb
      User.create_from_fb_connect(facebook_session.user)
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
    current_user.state='active'
    current_user.activated_at = Time.now.utc
    current_user.save(false)
    
    redirect_back_or_default('/')

  end

end
