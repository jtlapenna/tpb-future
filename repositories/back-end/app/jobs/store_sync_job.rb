class StoreSyncJob < ApplicationJob
  queue_as :stores_sync

  def perform(store_id)
    # Do something later
    Rails.logger.info "Store sync for store_id: #{store_id}"
   
    begin
       store = Store.find(store_id)

      # Finish all pending and in_progress previus syncs
      store.store_syncs.where.not(status: :finished).each(&:finished!)
    # capture any active record error not found / connection error etc
    rescue => e
      Rails.logger.error "Error syncing store_id: #{store_id} Error --- #{e} --- #{e.backtrace}"
      notify_error_by_mail(store_id, e)
      Airbrake.notify(e, params: { store_id: store_id })
      return
    end
    


    begin
      if parser = store.api_parser
        result = parser.parse

        if result[:errors].blank?
          sync = result[:sync]
          sync.process_items

          # Just for POS integrations (treez, flowhub, etc), update stock if non-automatched products
          update_non_auto_matched_products(sync, store) if store.api_type.present?

          Rails.logger.info "Finish sync store: #{store_id}"
        else
          Rails.logger.error "Error syncing store_id: #{store_id} Error -- #{result[:errors]}"
          Rails.logger.error result[:errors]
          ApiSyncMailer.sync_error(store_id, errors: result[:errors]).deliver_later
          Airbrake.notify(
            "Error syncing store_id: #{store_id}",
            params: { errors: result[:errors] }
          )
        end
      end
    rescue StandardError => e
      Rails.logger.error "Error syncing store_id: #{store_id} Error --- #{e} --- #{e.backtrace}"

      unless skip_notification?(e)
        notify_error_by_mail(store_id, e)
        Airbrake.notify(e, params: { store_id: store_id })
      end
    end
  end

  private

  def update_non_auto_matched_products(sync, catalog)
    matched_ids = sync.reload.store_sync_items.auto_matched.map(&:store_product_id)

    if catalog.api_settings["api_type"] != "covasoft"
      catalog.store_products
             .where
             .not(id: matched_ids).where.not(stock: 0)
             .update_all(StoreProduct.touch_attributes_with_time.merge(stock: 0))
    end
  end

  def notify_error_by_mail(store_id, error)
    errors = [error.message]

    if error.is_a?(Errors::ServiceUnavailable)
      errors += ['', 'Context:']
      errors += error.context.map { |key, value| "#{key}: #{value}" }
    end

    errors += ['', 'Backtrace:']
    errors += error.backtrace

    ApiSyncMailer.sync_error(store_id, exception: errors).deliver_later
  end

  def skip_notification?(error)
    (error.is_a?(Errors::ServiceUnavailable) && skip_service_unavailable_notification?) ||
      skip_all_notifications?
  end

  def skip_service_unavailable_notification?
    ENV['STORE_SYNC_SKIP_SERVICE_UNAVAILABLE_NOTIFICATION'] == 'true'
  end

  def skip_all_notifications?
    ENV['STORE_SYNC_SKIP_ALL_NOTIFICATION'] == 'true'
  end
end
