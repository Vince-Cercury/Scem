class FacebookRetrieveFriendsJob < Struct.new(:user_id, :facebook_user)
  def perform

    user = User.find(user_id)
#    i=1;

    #for each friends we retrieve the first name, last name and small pic
    #we put that in an array of keys, values
    #this array is then added to facebook_friends_info array field
    user.facebook_friends_info = Array.new
    facebook_friends = facebook_user.friends!(:profile_url, :first_name, :last_name, :pic_square, :uid)
    facebook_friends.each do |fb_friend|
      friend_useful_data = Hash.new
      friend_useful_data['uid'] = fb_friend.uid
      friend_useful_data['profile_url'] = fb_friend.profile_url
      friend_useful_data['first_name'] = fb_friend.first_name
      friend_useful_data['last_name'] = fb_friend.last_name
      friend_useful_data['pic_square'] = fb_friend.pic_square
      user.facebook_friends_info << friend_useful_data

      #every 50 users, we save the list.
      ##This way, the user can start to use it even if it's not complete
#      if(i==50)
#        user.set_validate_password(false)
#        user.set_validate_email(false)
#        user.save!
#        i=1
#      else
#        i +=1;
#      end


    end



    #we don't want to validate password
    user.set_validate_password(false)
    user.set_validate_email(false)
    user.save!
    #raise user.facebook_friends_info.inspect
  end
end