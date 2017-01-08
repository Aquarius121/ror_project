set :stage, :staging
set :chruby_ruby, '2.2'
set :rails_env, :staging

#set :branch, '15_inaccurate-line-on-map'
set :branch, 'staging'

set :ssh_options, {
    forward_agent: true
}

set :rvm_roles, [:some]
set :rvm_map_bins, []

server '46.22.223.59', user: 'deploy', roles: %w(web app db)
