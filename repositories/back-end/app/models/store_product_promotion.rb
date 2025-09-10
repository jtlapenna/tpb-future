class StoreProductPromotion < ApplicationRecord
  belongs_to :store_product

  validates :store_product_id, presence: true, uniqueness: true
  validates :promotion, length: { maximum: 20 }

  after_create_commit :notify_store_product_create
  after_update_commit :notify_store_product_update
  after_destroy_commit :notify_store_product_destroy

  def notify_store_product_create
    store_product = StoreProduct.find(self.store_product_id)
    # update store product last_updated_websocket with current time
    store_product.update(last_updated_websocket: Time.current)
  end

  def notify_store_product_update
    relevant_fields = ['promotion', 'store_product_id', 'promotion_id', 'promotion_name', 'discount_price']
    changed_fields = self.previous_changes.keys & relevant_fields
    if changed_fields.any?
      store_product = StoreProduct.find(self.store_product_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    store_product = StoreProduct.find(self.store_product_id)
    # update store product last_updated_websocket with current time
    store_product.update(last_updated_websocket: Time.current)
  end
end

# == Schema Information
#
# Table name: store_product_promotions
#
#  id               :bigint           not null, primary key
#  discount_price   :decimal(10, 2)   default(0.0)
#  discount_type    :string
#  promotion        :text
#  promotion_name   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  promotion_id     :string
#  store_product_id :bigint           not null
#
# Indexes
#
#  index_store_product_promotions_on_store_product_id  (store_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_product_id => store_products.id)
#
