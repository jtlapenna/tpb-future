class ExpiredKioskProduct < ApplicationRecord

  belongs_to :store_product, optional: true
  belongs_to :store, optional: true
  belongs_to :kiosk, optional: true

  validates :expired_at, presence: true
  validates :last_updated_at, presence: true

  scope :active, -> { where active: true }


end

# == Schema Information
#
# Table name: expired_kiosk_products
#
#  id               :bigint           not null, primary key
#  expired_at       :datetime
#  last_updated_at  :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  kiosk_id         :bigint           not null
#  store_id         :bigint           not null
#  store_product_id :string
#
# Indexes
#
#  index_expired_kiosk_products_on_kiosk_id  (kiosk_id)
#  index_expired_kiosk_products_on_store_id  (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_id => kiosks.id)
#  fk_rails_...  (store_id => stores.id)
#
