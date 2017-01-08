json.array!(@rides) do |route|
  json.extract! route, :id, :title, :created_at, :encoded_path
  json.ridedate route.ridedate.to_formatted_s(:short_ordinal)
  json.type route.my_ride_type(current_user)
  json.distance meters_to_mile(route.ride_distance).to_s
  json.time seconds_to_time(route.ride_time).to_s
  json.updated_at route.updated_at.to_time.to_i
end
