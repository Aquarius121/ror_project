json.array!(@my_rides) do |route|
  json.extract! route, :id, :title
  json.ridedate route.ridedate ? route.ridedate.to_formatted_s(:long_ordinal) : ''
  json.type route.my_ride_type(current_user)
  json.distance meters_to_mile(route.ride_distance)
  json.time seconds_to_time(route.ride_time)
  json.updated_at route.updated_at.to_time.to_i
end
