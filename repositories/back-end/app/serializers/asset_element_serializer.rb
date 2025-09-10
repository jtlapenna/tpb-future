class AssetElementSerializer < ActiveModel::Serializer
  attributes :id, :link, :coord_x, :coord_y, :element_type

  has_one :asset
end
