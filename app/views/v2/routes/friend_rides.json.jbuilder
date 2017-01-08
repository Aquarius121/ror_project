json.array!(@rides) do |route|
  json.extract! route, :id, :title, :created_at, :updated_at,
                       :ridedate, :description, :ride_distance
  json.static_map_url route.static_map_url
  json.user_avatar avatar_url_for_ride(route)
  json.type route.my_ride_type(current_user)
  json.time seconds_to_time(route.ride_time).to_s
end


