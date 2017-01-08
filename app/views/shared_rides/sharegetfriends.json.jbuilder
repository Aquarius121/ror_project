json.shared (@shared_friends) do |friend|
  json.id friend.id
  json.name friend.full_name
end

json.friends (Friendship.list_friends(current_user)) do |friend|
  json.id friend.id
  json.name friend.full_name
end

