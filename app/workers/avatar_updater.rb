  class AvatarUpdater
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    user.update_avatar
  end
end
