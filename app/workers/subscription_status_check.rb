class SubscriptionStatusCheck
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    subscription_id = user.subscription && user.subscription.transaction_id

    unless subscription_id
      STDOUT.puts "User #{user.email} has no transaction_id"
      return
    end

    response = Payment.check_subscription_status subscription_id
    STDOUT.puts "User #{user.email} subscription status: #{response.subscription_status}"
    if response.subscription_status && response.subscription_status != 'active' && !user.role?(:free)
      user.free!
      NotificationMailer.subscription_suspended(user_id).deliver
    end
  end
end