json.extract! @user,
              :id, :firstname, :lastname, :location, :zip, :followers_count,
              :following_count
json.recent_ride @recent_ride
json.rides_count @rides_stats.count
json.distance meters_to_mile(@rides_stats.distance)
json.time seconds_to_screen(@rides_stats.time)
json.total_time_in_seconds @rides_stats.time

json.avatar avatar_url(@user, :small)
json.role @user.role.name.downcase
