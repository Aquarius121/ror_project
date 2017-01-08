module RoutesHelper
  
  def my_rides
    render 'template/my_rides/my_rides'
  end

  def search_rides
    render 'template/my_rides/search_rides'
  end
  
  def ride_type_select
    render 'template/my_rides/ride_type_select'
  end
  
  def own_ride_left_popup
    render 'template/my_rides/own_ride_left'
  end
  
  def own_ride_right_popup
    render 'template/my_rides/own_ride_right'
  end
  
  def list_my_rides
    render :partial => 'template/my_rides/ride', :collection => Route.without_data.all_for_user(current_user.id).by_created_at
  end

  def avatar_url_for_ride(route)
    route.user.avatar_id? ? Attachment.find(route.user.avatar_id).file.url(:thumb, timestamp: false) : route.user.avatar_url
  end
  
end
