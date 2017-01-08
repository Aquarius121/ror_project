desc 'Notify users about card expiration via email'
task :cc_expiration => :environment do
  users = User.with_expiring_card
  STDOUT.puts "Users to notify: #{users.count}"
  users.each do |user|
    CCExpirationNotificator.perform_async(user.id)
  end
end