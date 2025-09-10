class StoreSyncItemSerializer < ActiveModel::Serializer
  attributes :id, :sku, :name, :size_name, :category, :stock, :brand, :status, :store_product_id
end
