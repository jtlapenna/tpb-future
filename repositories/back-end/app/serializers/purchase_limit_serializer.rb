class PurchaseLimitSerializer < ActiveModel::Serializer
  attributes :id, :name, :limit, :store_category_ids
end
