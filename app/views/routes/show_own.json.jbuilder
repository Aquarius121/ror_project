json.array!(@routes) do |route|
  json.extract! route, :id, :title, :surface_id, :rating, :elevation, :description,
                :privacy_id, :condition_id, :encoded_path, :is_readonly, :max_lean, :average_speed, :max_speed
  json.ridedate route.ridedate.to_formatted_s(:long_ordinal)
  json.url route_url(route, format: :json)
  json.avatar current_user_avatar
  json.distance meters_to_mile(route.ride_distance)
end
