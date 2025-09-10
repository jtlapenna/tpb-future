class AttributeValue < ApplicationRecord
  belongs_to :attribute_def
  belongs_to :target, polymorphic: true, inverse_of: :attribute_values, touch: true

  validates :value, presence: true

  scope :with_name, ->(name) { joins(:attribute_def).merge(AttributeDef.by_name(name)) }

  after_create_commit :notify_store_product_create
  after_update_commit :notify_store_product_update
  after_destroy_commit :notify_store_product_destroy

  def notify_store_product_create
    if self.target_type == 'StoreProduct'
      store_product = StoreProduct.find(self.target_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_update
    relevant_fields = ['attribute_def_id', 'value', 'target_id', 'target_type']
    changed_fields = self.previous_changes.keys & relevant_fields
    if self.target_type == 'StoreProduct' && changed_fields.any?
      store_product = StoreProduct.find(self.target_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    if self.target_type == 'StoreProduct' && self.target_id
      store_product = StoreProduct.find_by(id: self.target_id)
      if store_product
        # update store product last_updated_websocket with current time
        store_product.update(last_updated_websocket: Time.current)
      end
    end
  end
end

# == Schema Information
#
# Table name: attribute_values
#
#  id               :bigint           not null, primary key
#  target_type      :string
#  value            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  attribute_def_id :bigint
#  target_id        :integer
#
# Indexes
#
#  index_attribute_values_on_attribute_def_id           (attribute_def_id)
#  index_attribute_values_on_target_and_def             (target_id,target_type,attribute_def_id)
#  index_attribute_values_on_target_id                  (target_id)
#  index_attribute_values_on_target_id_and_target_type  (target_id,target_type)
#  index_attribute_values_on_target_type                (target_type)
#
# Foreign Keys
#
#  fk_rails_...  (attribute_def_id => attribute_defs.id)
#
