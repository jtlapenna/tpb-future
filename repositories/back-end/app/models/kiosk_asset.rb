class KioskAsset < ApplicationRecord
  belongs_to :text_position, class_name: 'LayoutPosition', optional: true
  belongs_to :asset_position, class_name: 'LayoutPosition', optional: true
  belongs_to :section_position, class_name: 'LayoutPosition', optional: true

  belongs_to :kiosk_layout, inverse_of: :kiosk_assets

  has_one :asset, as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank

  has_many :asset_elements, dependent: :destroy
  accepts_nested_attributes_for :asset_elements, allow_destroy: true, reject_if: :all_blank
end

# == Schema Information
#
# Table name: kiosk_assets
#
#  id                  :bigint           not null, primary key
#  code                :string
#  secondary_text      :text
#  text                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  asset_position_id   :integer
#  kiosk_layout_id     :integer
#  section_position_id :integer          default(10)
#  text_position_id    :integer
#
# Indexes
#
#  index_kiosk_assets_on_kiosk_layout_id  (kiosk_layout_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_layout_id => kiosk_layouts.id)
#
