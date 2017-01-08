# == Schema Information
#
# Table name: friendships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  user_id     :integer
#  active      :boolean
#  date        :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Friendship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User', :foreign_key => 'follower_id'
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  scope :requested, ->(user_id, friend_id) {
    where(follower_id: user_id, user_id: friend_id)
  }

  scope :approved, ->(user_id, friend_id) {
    where('(follower_id = ? AND user_id = ?) OR (follower_id = ? AND user_id = ?)', user_id, friend_id, friend_id, user_id)
  }

  def self.is_friend_request?(friend, user)
    friendship = Friendship.requested(user.id, friend.id).count
    friends = user.fb_friends ? user.is_friends_with?(friend.id) : friend.is_friends_with?(user.id)
    friendship == 1 && !friends
  end

  def self.list_friends(user)
    site_friends = []
    users = User.joins(:friendship).where(friendships: {follower_id: user.id})
    site_friends += User.find(users.map(&:id) + user.fb_friends)
    site_friends.uniq { |x| x.id }
  end

  def self.suggest(user, request_ip = nil )
    db = MaxMindDB.new('./GeoLite2-City.mmdb')
    geo_ip = db.lookup(request_ip) if request_ip
    source = geo_ip && geo_ip.found? ? geo_ip.location : user
    lat, lon = source.latitude, source.longitude

    return [] if !(lat && lon)

    User
        .with_distance_to(lat, lon)
        .close_to(lat, lon, 25000)
        .where('NOT EXISTS(SELECT * FROM friendships fr  WHERE fr.follower_id = ? AND fr.user_id = users.id)', user.id)
        .joins('LEFT OUTER JOIN routes ON routes.user_id = users.id')
        .joins('LEFT OUTER JOIN members ON users.id = members.user_id AND members.active = TRUE').joins('LEFT OUTER JOIN clubs ON members.club_id = clubs.id')
        .group('users.id')
        .select('users.id, users.firstname, users.lastname, users.location, users.avatar_id, users.fb_id, users.email, MIN(clubs.title) as club_name, COUNT(routes.id) as routes_count, SUM(routes.ride_distance) as distance')
        .to_a
        .sort { |a, b| a.distance_between <=> b.distance_between }
        .reject { |u| u.id == user.id }
  end

end
