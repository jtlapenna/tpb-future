module Api
  module V1
    class BrandSerializer < ActiveModel::Serializer
      attributes :id, :name, :total_products, :description, :created_at, :updated_at

      has_one :logo

      def total_products
        object.kiosk_products_count
      end
    end
  end
end
