set :stage, :production
set :rvm_ruby_version, '2.1.1'
set :rails_env, :production

set :ssh_options, {
   keys: [File.join(ENV["HOME"], ".ssh", "ridingsocial.pem")],
   forward_agent: true
}

server 'ec2-54-187-178-75.us-west-2.compute.amazonaws.com', user: 'ec2-user', roles: %w(web app db)