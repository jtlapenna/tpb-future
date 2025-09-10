class StoreTax < ApplicationRecord
  belongs_to :store

  validates :name, presence: true, uniqueness: { scope: :store_id }
  validates :value, presence: true

  scope :owner, lambda { |owner|
    joins(:store).merge(Store.owner(owner))
  }

  # Commented because wil finish message to Pusher

  # after_update_commit :notify_store_product_update
  # after_create_commit :notify_store_product_create
  # after_destroy_commit :notify_store_product_destroy
  #
  # def notify_store_product_create
  #   store_products = StoreProduct.where(store_id: self.store_id)
  #   store_products.each do |store_product|
  #     # update store product last_updated_websocket with current time
  #     store_product.update(last_updated_websocket: Time.current)
  #   end
  # end
  #
  # def notify_store_product_update
  #   relevant_fields = ['name', 'value']
  #   changed_fields = self.previous_changes.keys & relevant_fields
  #   if changed_fields.any?
  #     store_products = StoreProduct.where(store_id: self.store_id)
  #     store_products.each do |store_product|
  #       # update store product last_updated_websocket with current time
  #       store_product.update(last_updated_websocket: Time.current)
  #     end
  #   end
  # end
  #
  # def notify_store_product_destroy
  #   store_products = StoreProduct.where(store_id: self.store_id)
  #   store_products.each do |store_product|
  #     # update store product last_updated_websocket with current time
  #     store_product.update(last_updated_websocket: Time.current)
  #   end
  # end
end

# == Schema Information
#
# Table name: store_taxes
#
#  id       :bigint           not null, primary key
#  name     :string
#  value    :float
#  store_id :bigint
#
# Indexes
#
#  index_store_taxes_on_store_id  (store_id)
#
