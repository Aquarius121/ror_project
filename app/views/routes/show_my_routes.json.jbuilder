json.array!(@routes) do |route|
  json.extract! route, :id, :title, :surface_id, :rating, :description, :privacy_id,
                :condition_id, :completed, :encoded_path, :is_readonly, :max_lean, :average_speed, :max_speed

  json.ridedate route.ridedate ? route.ridedate.to_formatted_s(:long_ordinal) : ''
  json.url route_url(route, format: :json)
  json.distance meters_to_mile(route.ride_distance)
  json.elevation meters_to_feet(route.elevation)
  json.type route.my_ride_type(current_user)

  json.formatted_time seconds_to_time_short(route.ride_time).to_s
  json.formatted_created_at route.created_at.to_formatted_s(:short_ordinal)
end
