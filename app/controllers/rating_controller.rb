class RatingController < ApplicationController

  def rate
    @current_object = params[:parent_type].constantize.find(params[:parent_id])
    Rating.delete_all(["rateable_type = ? AND rateable_id = ? AND user_id = ?",
        params[:parent_type], params[:parent_id], current_user.id])
    @current_object.add_rating Rating.new(:rating => params[:rating],
      :user_id => current_user.id)
  end


end
