class AdConfig < ApplicationRecord
    enum template: { image: 0, video: 1 }

    belongs_to :kiosk    
    belongs_to :kiosk_product, optional: true
    belongs_to :brand, optional: true

    has_one :asset, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :destroy
    accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank

    has_one :store_product, :through => :kiosk_product
    
    has_paper_trail on: %i[update destroy]

    scope :owner, lambda { |owner|
        joins(:kiosk).merge(Kiosk.owner(owner))
      }

    scope :sorted, -> { order(id: :asc) }
    scope :sorted_by_availability, -> { includes(:store_product).order('store_products.stock=0 AND store_products.stock IS NOT NULL DESC, store_products.stock IS NULL DESC, ad_configs.id ASC') }
end

# == Schema Information
#
# Table name: ad_configs
#
#  id                  :bigint           not null, primary key
#  name                :string
#  use_brand_spotlight :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  brand_id            :bigint
#  kiosk_id            :bigint
#  kiosk_product_id    :bigint
#
# Indexes
#
#  index_ad_configs_on_brand_id          (brand_id)
#  index_ad_configs_on_kiosk_id          (kiosk_id)
#  index_ad_configs_on_kiosk_product_id  (kiosk_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id)
#  fk_rails_...  (kiosk_id => kiosks.id)
#  fk_rails_...  (kiosk_product_id => kiosk_products.id)
#
