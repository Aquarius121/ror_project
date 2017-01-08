desc 'Check Apple Push Notifications Feedback and remove tokens that fail to deliver'
task :check_apn_feedback => :environment do
  client = Houston::Client.production
  client.certificate = File.read("#{Rails.root}/config/certs/apn_production.pem")
  client.passphrase = 'asfdasfd'

  client.devices.each do |token|
    STDOUT.puts "Token #{token} revoked."
    user = User.where('? = ANY (device_tokens)', token )
    user.device_tokens = user.device_tokens - [token]
    user.save!
  end
end