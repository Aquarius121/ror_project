class CCExpirationNotificator
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    user.notify_about_cc_expiration unless user.cc_expiration_notification_sent?
  end
end