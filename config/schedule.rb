# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
# Learn more: http://github.com/javan/whenever

set :output, '/var/www/butlermaps/shared/log/cron.log'

if @environment == 'production'
  every 10.minutes do
    rake 'cc_operation'
  end

  every 1.hour do
    rake 'pg:backup'
    command 'rsync -av /var/www/butlermaps/shared deploy@46.22.223.59:/home/deploy/backups/prod_shared_bkp'
  end

  every 1.day, :at => '2am' do
    rake 'subscription_status'
  end

  every 1.day, :at => '5am' do
    rake 'cc_expiration'
  end

  every 1.day, :at => '5pm' do
    rake 'check_apn_feedback'
  end
end

every 1.day, :at => '4am' do
  rake 'get_zip_code'
end





