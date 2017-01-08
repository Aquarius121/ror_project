json.extract! @club, :id, :title, :description, :location, :privacy_id, :club_type_id, :created_at, :updated_at
json.logo club_logo_url(@club, :small)
json.in_club @in_club
json.approved @approved
json.owner @club.is_owner?(current_user)
json.approve_count @approve_count
json.add_to_friend_url friendships_path
json.members_count @members_count
json.rides_count @rides_count
json.riding_preferences @club.riding_preferences
json.members {
  json.array!(@members) do |user|
    json.extract! user, :id, :firstname, :lastname, :location
    json.avatar_small avatar_url(user, :thumb)
    json.avatar_big avatar_url(user, :small)
    json.friends current_user.is_friends_with?(user.id)
  end
}