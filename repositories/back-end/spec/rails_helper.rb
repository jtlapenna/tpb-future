# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
ENV['TREEZ_API_URL'] = 'https://api.treez.io'
ENV['TREEZ_API_KEY'] = 'TREEZ_API_SECRET_KEY'
ENV['HEADSET_API_URL'] = 'https://insights.headset.io'
ENV['HEADSET_API_PARTNER'] = 'thepeakbeyond'
ENV['FLOWHUB_API_URL'] = 'https://api.flowhub.co'
ENV['FLOWHUB_AUTH_URL'] = 'https://flowhub.auth0.com'
ENV['EZ_TEXTING_API_URL'] = 'http://ez.texting.api'
ENV['LEAFLOGIX_API_URL'] = 'https://leaflogix-publicapi.azurewebsites.net'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'sidekiq/testing'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Mute sidekiq cron info logs
Sidekiq.logger.level = Logger::INFO

RSpec.configure do |config|
  config.include RequestsHelper::JsonHelpers, type: :request
  config.include RequestsHelper::AuthHelpers, type: :controller
  config.include RequestsHelper::AuthHelpers, type: :request
  config.include CustomMatchers::Product
  config.include CustomMatchers::Attribute
  config.include CustomMatchers::Kiosk
  config.include CustomMatchers::Store

  config.after(:suite) do
    Sidekiq::Cron::Job.destroy_all!
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
