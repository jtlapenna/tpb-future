module Api
  module V1
    class KioskProductMinimalSerializer < ActiveModel::Serializer
      attribute :id do
        object.store_product_id
      end

      attribute :sku do
        @object.store_sku
      end

      attribute :stock do
        @object.store_stock
      end

      attributes :updated_at, :created_at
    end
  end
end
