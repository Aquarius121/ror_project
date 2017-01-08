json.array!(@users) do |user|
  json.extract! user, :id, :firstname, :lastname, :location, :friendship_id
  json.avatar avatar_url(user, :small)
json.add_url friendships_path
end
