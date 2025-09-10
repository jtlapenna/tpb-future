class CreateShopifyWebhookJob < ApplicationJob
  queue_as :customer_sync

  def perform(store_id)
    store = Store.find_by(id: store_id)

    if store && store.api_type_shopify?
      Rails.logger.info "Creating shopify webhook for #{store.name}: #{store_id}"

      store.set_shopify_base_url
      webhooks = ShopifyAPI::Webhook.find(:all)

      store_webhooks = webhooks.select{|webhook| webhook.address.include?("stores/#{store.id}/webhooks")}
      webhook_types = store_webhooks.map{|webhook| webhook.topic}

      store.webhook_url.each do |topic, end_point|
        unless webhook_types.include?(topic)
          ShopifyAPI::Webhook.create(
            address: webhook_address(store.webhook_url[topic]),
            topic: topic,
            format: "json"
          )

          Rails.logger.info "Created webhook for #{topic}"
        end
      end

      store.clear_shopify_session
    end
  end

  def webhook_address(end_point)
    "https://#{ENV['CONFIG_HOST']}#{end_point}"
  end
end
