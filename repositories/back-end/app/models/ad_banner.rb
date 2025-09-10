class AdBanner < ApplicationRecord  

  belongs_to :store
  belongs_to :ad_banner_location

  has_many :images, as: :imageable, inverse_of: :imageable, dependent: :nullify
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  belongs_to :advertisable, polymorphic: true, optional: true

  has_one :advertisable_image, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :destroy
  accepts_nested_attributes_for :advertisable_image, allow_destroy: true, reject_if: :all_blank

  has_many :videos, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :videos, allow_destroy: true, reject_if: :all_blank
  
  validates :ad_banner_location, presence: true
  validates :ad_banner_location, uniqueness: { scope: :store}
end

# == Schema Information
#
# Table name: ad_banners
#
#  id                    :bigint           not null, primary key
#  advertisable_type     :string
#  callback_url          :string
#  disabled              :boolean          default(FALSE)
#  text                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  ad_banner_location_id :bigint           not null
#  advertisable_id       :bigint
#  store_id              :bigint           not null
#
# Indexes
#
#  index_ad_banners_on_ad_banner_location_id                  (ad_banner_location_id)
#  index_ad_banners_on_advertisable_type_and_advertisable_id  (advertisable_type,advertisable_id)
#  index_ad_banners_on_store_id                               (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (ad_banner_location_id => ad_banner_locations.id)
#  fk_rails_...  (store_id => stores.id)
#
