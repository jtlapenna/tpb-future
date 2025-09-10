module Api
  module V1
    class VideoImageBackgroundAssetSerializer < ActiveModel::Serializer
      attributes :id, :asset_position, :created_at, :updated_at

      def asset_position
        object.asset_position&.label
      end

      has_one :asset, serializer: Api::V1::AssetSerializer
    end
  end
end