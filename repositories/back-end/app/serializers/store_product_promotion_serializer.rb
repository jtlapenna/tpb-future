class StoreProductPromotionSerializer < ActiveModel::Serializer
    attributes :id, :promotion, :store_product_id, :promotion_id, :promotion_name, :discount_price

    belongs_to :store_product, serializer: StoreProductWithValuesSerializer
end