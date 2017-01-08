json.array!(@my_rides) do |route|
  json.extract! route, :id, :title, :ridedate, :ride_distance, :updated_at
  json.type route.my_ride_type(current_user)
  json.time seconds_to_time(route.ride_time)
  json.static_map_url route.static_map_url
  json.user_avatar avatar_url_for_ride(route)
end
