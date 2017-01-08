json.extract! @route, :id, :title, :surface_id, :rating, :data, :description, :ride_type_id,
              :privacy_id, :condition_id, :created_at, :updated_at, :encoded_path,
              :is_readonly, :ride_time, :max_lean, :average_speed, :max_speed
json.owner @owner
json.distance meters_to_mile(@route.ride_distance)
json.elevation meters_to_feet(@route.elevation)
json.time seconds_to_screen(@route.ride_time)
json.ridedate @route.ridedate ? @route.ridedate.strftime('%m/%d/%Y') : ''
json.surface @route.surface_id ? Surface.find(@route.surface_id).title : ''
json.images @images
json.type @route.my_ride_type(current_user)
json.formatted_time seconds_to_time_short(@route.ride_time)
json.formatted_created_at @route.created_at.to_formatted_s(:short_ordinal)
json.route_count_exceeded current_user.route_count_exceeded?
json.rider_name @route.user.full_name
json.updated_at @route.updated_at.to_time.to_i
