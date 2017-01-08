class V2::RoutesController < RoutesController

  def friend_rides
    @rides = Route.friend_rides(current_user, params[:friend_id])
  end

  def my_rides
    @my_rides = Route.all_for_user(current_user.id)
  end

  def show
    # guess we can give em rider_id
    # @owner = @route.user_id == current_user.id

    if can_access_comments?(@route, current_user)
      @comments = Comment.where(:related_id => @route.id).to_a
    else
      @comments = false
    end
    data = @route.decoded_route_data
     @points = (data['route_data']||[]).each_with_index.map do |point, i|
       h = {lat: point[0].round(5), lon: point[1].round(5), ord:i}
       h[:alt] = point[2] if point[2]
       h
     end
    @waypoints = (data['waypoints']||[]).each_with_index.map do |wp, i|
      {lat: wp['latitude'].round(5), lon: wp['longitude'].round(5), title: wp['location'], ord: i}
    end
  end

end
