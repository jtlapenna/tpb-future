class BrandAndStoreCategory < ApplicationRecord
  belongs_to :brand
  belongs_to :store_category
  has_many :rfid_products, foreign_key: :rfid_entity_id, dependent: :destroy

  validates :brand_id, uniqueness: { scope: :store_category_id }

  def name
    "#{brand.name}"
  end
end

# == Schema Information
#
# Table name: brand_and_store_categories
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  brand_id          :bigint           not null
#  kiosk_id          :bigint           not null
#  store_category_id :bigint           not null
#
# Indexes
#
#  index_brand_and_store                                  (brand_id,store_category_id) UNIQUE
#  index_brand_and_store_categories_on_brand_id           (brand_id)
#  index_brand_and_store_categories_on_kiosk_id           (kiosk_id)
#  index_brand_and_store_categories_on_store_category_id  (store_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id)
#  fk_rails_...  (kiosk_id => kiosks.id)
#  fk_rails_...  (store_category_id => store_categories.id)
#
