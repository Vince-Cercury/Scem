# To change this template, choose Tools | Templates
# and open the template in the editor.

class FacebookTools
  def initialize
    
  end

  def self.get_user_friends(user, search = '')

    to_display_fb_user = Facebooker::User.new(user.fb_user_id)

    #build a list of SCEM users from the list of Facebook users (if registered on this app)
    friends = Array.new
    facebook_friends = to_display_fb_user.friends

    #raise facebook_friends.inspect
    facebook_friends.each do |facebook_friend|
      #if User.facebook_user_accepted_this_app?(facebook_friend.uid)
      a_friend = User.find_by_fb_user_id(facebook_friend.uid)
      if !a_friend.nil?
        #raise a_friend.login.inspect
        #this allows us simulate a search on an array (usualy down at the model level with active record)
        #because we are not dealing with database, but data from facebooker api
        if !search.blank?
          if a_friend.login.downcase.include?(search.downcase) or a_friend.first_name.downcase.include?(search.downcase) or a_friend.last_name.downcase.include?(search.downcase)
            friends << a_friend           
          end
        else
          friends << a_friend
        end
      end
    end
    return friends
  end

end
