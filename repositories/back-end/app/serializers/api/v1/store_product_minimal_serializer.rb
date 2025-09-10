module Api
  module V1
    class StoreProductMinimalSerializer < ActiveModel::Serializer
      attributes :id, :sku, :created_at

      attribute :updated_at do
        [object.updated_at, object.product_variant.updated_at, object.product.updated_at].max
      end
    end
  end
end
