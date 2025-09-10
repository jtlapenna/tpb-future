module Api
  module V1
    class StoreCategoryMinimalSerializer < ActiveModel::Serializer
      attributes :id, :name, :created_at, :updated_at, :order
      belongs_to :store, serializer: StoreMinimalSerializer
      has_many :store_category_taxes
      has_one :banner, serializer: Api::V1::AssetSerializer
    end
  end
end
