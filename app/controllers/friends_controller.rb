class FriendsController < ApplicationController
  layout false

  def view
  end
  
  def route
    @route = Route.find(params[:id])
  end

  def index
    @friends = current_user.friends.sort { |a, b| (a.lastname || '').downcase <=> (b.lastname || '').downcase }
    @friend_rides = Route.for_friend(@friends.map(&:id)).order(:user_id, :created_at).to_a.group_by {|r| r.user_id}
  end

end
