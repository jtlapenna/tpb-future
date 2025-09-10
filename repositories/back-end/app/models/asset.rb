class Asset < ApplicationRecord
  validates :url, presence: true

  belongs_to :source, polymorphic: true, touch: true

  after_create_commit :notify_source_create
  after_update_commit :notify_source_update
  after_destroy_commit :notify_source_destroy

  def notify_source_create
    if self.source_type == 'StoreProduct'
      store_product = StoreProduct.find(self.source_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_source_update
    relevant_fields = ['url', 'source_type', 'source_id']
    changed_fields = self.previous_changes.keys & relevant_fields
    if self.source_type == 'StoreProduct' && changed_fields.any?
      store_product = StoreProduct.find(self.source_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_source_destroy
    if self.source_type == 'StoreProduct'
      store_product = StoreProduct.find(self.source_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end
end

# == Schema Information
#
# Table name: assets
#
#  id          :bigint           not null, primary key
#  source_type :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer
#
