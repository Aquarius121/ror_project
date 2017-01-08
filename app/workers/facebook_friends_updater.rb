class FacebookFriendsUpdater
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    return if user.fb_token.blank?
    begin
      Rails.logger.info 'gonna hit fb server'
      facebook_graph = ::Koala::Facebook::API.new(user.fb_token)
      friends = facebook_graph.get_connections(user.fb_id, 'friends')
      fb_ids = friends.map {|friend| friend['id']}
      #find users by fb id and return their ids as array
      friends_from_fb = User.where(fb_id: fb_ids).pluck(:id)
      user.update(fb_friends_ids: friends_from_fb, fb_fetched_at: Time.zone.now, fb_session_expired: false)
    rescue => e
      Rails.logger.error e.inspect
      user.update(fb_fetched_at: Time.zone.now, fb_session_expired: true)
    end
  end
end
