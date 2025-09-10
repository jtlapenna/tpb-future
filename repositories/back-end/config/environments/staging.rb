# Based on production defaults
require Rails.root.join('config/environments/production')

Rails.application.configure do
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'],
    port: ENV['SMTP_PORT'],
    user_name: ENV['SMTP_USER'],
    password: ENV['SMTP_PASSWORD'],
    enable_starttls_auto: true
  }
end
