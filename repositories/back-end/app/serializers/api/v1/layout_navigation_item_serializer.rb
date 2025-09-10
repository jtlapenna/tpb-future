module Api
  module V1
    class LayoutNavigationItemSerializer < ActiveModel::Serializer
      attributes :id, :label, :link, :title, :description, :order, :created_at, :updated_at

      has_one :asset, serializer: Api::V1::AssetSerializer
    end
  end
end
