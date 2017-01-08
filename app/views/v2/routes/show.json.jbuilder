json.extract! @route, :id, :title, :surface_id, :rating, :description, :ride_type_id,
              :privacy_id, :condition_id, :created_at, :updated_at,
              :is_readonly, :ride_time, :max_lean, :average_speed, :max_speed,
              :ridedate, :ride_distance
# json.owner_id @owner
json.elevation meters_to_feet(@route.elevation)
json.ride_time seconds_to_time(@route.ride_time)
json.type @route.my_ride_type(current_user)
json.rider_id @route.user_id
json.ride @points
json.waypoints @waypoints
json.static_map_url @route.static_map_url
json.user_avatar avatar_url_for_ride(@route)

