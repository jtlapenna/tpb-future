class ProductValue < ApplicationRecord
  belongs_to :valuable, polymorphic: true, inverse_of: :product_values, touch: true

  validates :value, numericality: { greater_than_or_equal_to: 0 }

  after_update_commit :notify_store_product_update
  after_create_commit :notify_store_product_create
  after_destroy_commit :notify_store_product_destroy

  private

  def notify_store_product_create
    if self.valuable_type == 'StoreProduct'
      store_product = StoreProduct.find(self.valuable_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_update
    relevant_fields = ['name', 'value', 'valuable_id', 'valuable_type']
    changed_fields = self.previous_changes.keys & relevant_fields
    if self.valuable_type == 'StoreProduct' && changed_fields.any?
      store_product = StoreProduct.find(self.valuable_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    Rails.logger.info "notify_store_product_destroy #{self.inspect}"
    if self.valuable_type == 'StoreProduct' && self.valuable_id
      store_product = StoreProduct.find_by(id: self.valuable_id)
      if store_product
        # update store product last_updated_websocket with current time
        store_product.update(last_updated_websocket: Time.current)
      end
    end
  end
end

# == Schema Information
#
# Table name: product_values
#
#  id            :bigint           not null, primary key
#  name          :string
#  valuable_type :string
#  value         :decimal(10, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  valuable_id   :bigint
#
# Indexes
#
#  index_product_values_on_valuable_type_and_valuable_id  (valuable_type,valuable_id)
#
