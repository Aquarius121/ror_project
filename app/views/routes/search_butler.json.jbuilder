json.array!(@rides) do |route|
  json.extract! route, :id, :title, :encoded_path, :ride_type_id
  json.distance meters_to_mile(route.ride_distance).to_s
  json.time seconds_to_time(route.ride_time).to_s
  json.start_location route.g1? ? route.start_location : ''
end
