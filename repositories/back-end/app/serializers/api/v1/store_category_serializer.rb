module Api
  module V1
    class StoreCategorySerializer < ActiveModel::Serializer
      attributes :id, :name, :order, :created_at, :updated_at

      has_one :banner, serializer: Api::V1::AssetSerializer
    end
  end
end
