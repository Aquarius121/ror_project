json.array!(@rides) do |route|
  json.extract! route, :id, :title, :encoded_path, :ride_type_id
  json.elevation meters_to_feet(route.elevation)
  json.ridedate route.ridedate ? route.ridedate.to_formatted_s(:long_ordinal) : ''
  json.type route.my_ride_type(current_user)
  json.distance meters_to_mile(route.ride_distance)
  json.time seconds_to_time(route.ride_time)
  json.formatted_time seconds_to_time_short(route.ride_time)
  json.formatted_created_at route.created_at.to_formatted_s(:short_ordinal)
  json.start_location route.g1? ? route.start_location : ''
end

