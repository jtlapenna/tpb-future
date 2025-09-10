class CustomerSyncJob < ApplicationJob
  queue_as :customer_sync
  unique :until_executed

  def perform(store_id)
    Rails.logger.info "Customer sync for store_id: #{store_id}"

    store = Store.find(store_id)
    api_key = store.api_key

    Rails.logger.info "Starting Customer sync for store_id: #{store_id} - external_account_id: #{api_key}"

    if CustomerSync.in_progress.where(store: store, external_account_id: api_key).exists?
      Rails.logger.info 'Another customer sync is running.'
    else
      sync = CustomerSync.create!(store: store, external_account_id: api_key)
      sync.do_process
    end

    Rails.logger.info "End customers sync for store_id: #{store} - external_account_id: #{api_key}"
  end
end
