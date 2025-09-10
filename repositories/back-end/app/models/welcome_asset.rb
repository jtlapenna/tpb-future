class WelcomeAsset < ApplicationRecord
  has_one :kiosk_layout, dependent: :nullify

  has_one :asset, as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank

  belongs_to :asset_position, class_name: 'LayoutPosition', optional: true

  validates :kiosk_layout, presence: true
end

# == Schema Information
#
# Table name: welcome_assets
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  asset_position_id :integer
#
