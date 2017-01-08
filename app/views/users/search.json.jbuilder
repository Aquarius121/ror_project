json.array!(@users) do |user|
  json.extract! user, :id, :firstname, :lastname, :location, :club_name, :routes_count
  json.avatar avatar_url(user, :small)
  json.follower_id current_user.id
  json.add_url friendships_path
  json.friends current_user.is_friends_with?(user.id)
  json.friend_request Friendship.is_friend_request?(user, current_user)
  json.params @params
  json.distance meters_to_mile(user.distance)
end
