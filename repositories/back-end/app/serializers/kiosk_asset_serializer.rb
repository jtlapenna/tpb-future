class KioskAssetSerializer < ActiveModel::Serializer
  attributes :id, :text, :secondary_text, :text_position_id, :asset_position_id,
             :section_position_id, :code

  has_many :asset_elements

  has_one :asset
end
