# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['EXECJS_RUNTIME'] = 'Node'
ENV['NODE'] = '/usr/local/bin/node'
ENV['NODE_PATH'] = '/usr/local/lib/node_modules'

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
