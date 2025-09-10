class VideoImageBackgroundAssetSerializer < ActiveModel::Serializer
  attributes :id, :asset_position_id

  has_one :asset
end