require 'csv'

class HeadsetApiParser
  def initialize(store_id:)
    @store_id = store_id
  end

  def store
    @store ||= Store.find(@store_id)
  end

  def parse
    store_sync = StoreSync.new(store_id: @store_id)
    result = { errors: [], sync: nil }
    errors = []

    products.each_with_index do |api_prod, index|
      item = StoreSyncItem.new(
        sku: api_prod[:sku],
        name: api_prod[:name],
        category: api_prod[:category],
        stock: safe_stock(api_prod[:quantityInStock]),
        brand: api_prod[:brand],
        store_sync: store_sync,
        active: true,
        prices: [{ name: api_prod[:unit], value: api_prod[:price] }]
      )

      if item.valid?
        store_sync.store_sync_items << item
      else
        # Index is 0 based
        result[:errors] << { row: index + 1, messages: item.errors.messages }
      end
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  private

  def safe_stock(stock)
    stock <= 0 ? 0 : stock
  end

  def products
    api_client.products
  end

  def api_client
    @api_client ||= Headset::ApiClient.new(
      api_partner: ENV['HEADSET_API_PARTNER'],
      api_key: store.api_key,
      api_store_id: store.api_store_id
    )
  end
end
