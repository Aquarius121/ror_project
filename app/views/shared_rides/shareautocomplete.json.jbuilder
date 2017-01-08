json.array!(@friends) do |friend|
  json.id friend.id
  json.name friend.full_name
end
