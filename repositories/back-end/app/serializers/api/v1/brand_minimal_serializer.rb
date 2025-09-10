module Api
  module V1
    class BrandMinimalSerializer < ActiveModel::Serializer
      attributes :id, :name, :created_at, :updated_at

      has_one :logo, serializer: Api::V1::AssetSerializer
    end
  end
end
