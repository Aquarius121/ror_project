json.array!(@friends) do |friend|
  json.extract! friend, :id, :firstname, :lastname
json.avatar_thumb avatar_url(friend, :thumb)
end