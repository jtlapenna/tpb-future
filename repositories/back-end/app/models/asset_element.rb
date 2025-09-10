class AssetElement < ApplicationRecord
  enum element_type: { picture_in_picture: 0, dot: 1 }

  belongs_to :kiosk_asset, inverse_of: :asset_elements

  has_one :asset, as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank
end

# == Schema Information
#
# Table name: asset_elements
#
#  id             :bigint           not null, primary key
#  coord_x        :string
#  coord_y        :string
#  element_type   :integer          default("picture_in_picture")
#  link           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  kiosk_asset_id :string
#
