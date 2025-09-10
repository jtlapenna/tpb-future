module Api
  module V1
    class AssetSerializer < ActiveModel::Serializer
      attributes :id, :url, :created_at, :updated_at
    end
  end
end
