desc 'Check user subscription status and downgrade to free'
task :subscription_status => :environment do
  users = User.with_active_subscription.to_a
  STDOUT.puts "Users to check: #{users.count}"

  subscriptions = Payment.get_inactive_subscriptions

  subscriptions.each do |subscription|
    user = users.find {|u| u.subscription && u.subscription.transaction_id == subscription.id}

    unless user
      STDOUT.puts "Failed to find user for subscription ##{subscription.id}"
      next
    end

    STDOUT.puts "User #{user.email} subscription status: #{subscription.status}"

    if subscription.status != 'active' && !user.role?(:free)
      user.free!
      NotificationMailer.subscription_suspended(user_id).deliver
    end

  end

end