require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

require 'ejs'
require 'bitcoin'

yaml = ERB.new(File.expand_path('../config.yml', __FILE__)).result
AppConfig = YAML.load_file(yaml)[Rails.env]

module BPS
  class Application < Rails::Application
    config.autoload_paths += %W(
      #{config.root}/app/presenters
      #{config.root}/app/services
      #{config.root}/lib
    )

    # http://stackoverflow.com/questions/7294479/assets-pipeline-when-updating-to-rails-3-1-on-heroku
    # This is need for Heroku 
    config.assets.initialize_on_precompile = false
    
    config.assets.enabled = true
    config.assets.version = '1.0'    

    config.encoding = "utf-8"
    config.filter_parameters += [:password]

    config.generators do |g|
      g.test_framework :rspec, views: false
    end

    config.assets.precompile += [
      'admin.css',
      'ie.css',
      'ie6.css',
      'ie7.css',
      'admin.js'
    ]
    
    config.action_mailer.default_url_options = {
      host:     AppConfig['domain'],
      protocol: AppConfig['protocol']
    }
  end
end
