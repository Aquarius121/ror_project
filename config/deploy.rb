set :application, 'butlermaps'
set :scm, :git
set :repo_url, 'git@bitbucket.org:6600feet/rs-website.git'
set :branch, 'master'
set :deploy_to, '/var/www/butlermaps/'
set :log_level, :info

set :linked_files, %w{config/database.yml GeoLite2-City.mmdb public/routes/g1_markers.json}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :bundle_jobs, 4
set :bundle_binstubs, nil
set :pty, false

set :disallow_pushing, true

namespace :deploy do
  namespace :nginx do
    desc 'Reload nginx configuration'
    task :reload do
      on roles :web do
        execute 'sudo service nginx restart'
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      #invoke 'nginx:reload'

      # Restarts Phusion Passenger
      execute :touch, release_path.join('tmp/restart.txt')
      invoke 'sidekiq:restart'
    end
  end

  after :finishing, :cleanup

end

after 'deploy:publishing', 'deploy:restart'

desc 'Get the cron log'
task :get_cron_log do
  on roles(:app), in: :sequence, wait: 5 do
    log = capture "tail -n200 #{release_path.join('log/cron.log')}"
    info log
  end
end

desc 'Get the app log'
task :get_app_log do
  on roles(:app), in: :sequence, wait: 5 do
    log = capture "tail -n100 #{release_path.join('log/production.log')}"
    info log
  end
end
