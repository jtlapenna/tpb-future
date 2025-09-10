require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  # Protect against timing attacks:
  # - See https://codahale.com/a-lesson-in-timing-attacks/
  # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
  # - Use & (do not use &&) so that it doesn't short circuit.
  # - Use digests to stop length information leaking
  # (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)

  sha_username = ::Digest::SHA256.hexdigest(username)
  sha_actual_username = ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_ADMIN_USERNAME'])
  sha_password = ::Digest::SHA256.hexdigest(password)
  sha_actual_password = ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_ADMIN_PASSWORD'])

  ActiveSupport::SecurityUtils.secure_compare(sha_username, sha_actual_username) &
    ActiveSupport::SecurityUtils.secure_compare(sha_password, sha_actual_password)
end

# Disable sidekiq retries. Handle deb with ActiveJob
Sidekiq.options[:max_retries] = 0

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule = [
      {
        'name'  => 'clean_old_active_carts',
        'class' => 'CleanActiveCartsJob',
        'cron'  => '0 * * * *',  # Runs every hour
        'queue' => 'clean_active_carts',
        'description' => 'Removes carts not updated in the last 1 hour'
      }
    ]

    Sidekiq::Cron::Job.load_from_array(schedule)
  end
end

# Sidekiq.configure_server do |config|
#   config.on(:startup) do
#     array = [
#       {
#         'name'  => 'clean_database',
#         'class' => 'CleanDatabaseJob',
#         'cron'  => '0 0 * * 0'
#       }
#     ]
#
#     if ENV['RAILS_ENV'] == 'development'
#       Sidekiq::Cron::Job.load_from_array array
#     end
#   end
# end
