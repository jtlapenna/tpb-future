module Api
  module V1
    class AssetElementSerializer < ActiveModel::Serializer
      attributes :id, :link, :coord_x, :coord_y, :created_at, :updated_at

      has_one :asset,
              serializer: Api::V1::AssetSerializer,
              if: -> { object.element_type == 'picture_in_picture' }
    end
  end
end
