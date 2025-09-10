class CleanActiveCartsJob < ApplicationJob
  queue_as :clean_active_carts

  def perform
    time_threshold = 1.hour.ago
    old_carts = Cart.where('updated_at < ?', time_threshold)

    old_carts.find_each(batch_size: 100) do |cart|
      cart.destroy
    end

    Rails.logger.info "Removed #{old_carts.count} carts not updated since #{time_threshold}"
  rescue => e
    Rails.logger.error "Error removing old carts: #{e.message}"
    notify_error_by_mail(e) if respond_to?(:notify_error_by_mail)
    Airbrake.notify(e) if defined?(Airbrake)
  end
end