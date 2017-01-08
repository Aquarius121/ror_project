require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Butlermaps
  class Application < Rails::Application

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), '../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), '../app/overrides/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      Rails.configuration.cache_classes ? require('./lib/units_converter.rb') : load('./lib/units_converter.rb')
    end

    # LOAD ADDONS
    config.react.addons = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = true
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'json').to_s
    config.assets.precompile += %w(admin_table.css v2.js v2.css)
    config.active_record.schema_format = :sql
    # Autload lib/*
    #config.autoload_paths += %W(#{config.root}/lib)

    # config.cache_store = :redis_store, 'redis://localhost:6379/3/cache', { expires_in: 90.minutes }
    PaperTrail.config.version_limit = 20

    config.active_record.raise_in_transactional_callbacks = true
  end
end
