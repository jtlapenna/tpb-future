class Image < ApplicationRecord
  validates :url, presence: true

  belongs_to :imageable, polymorphic: true, inverse_of: :images, touch: true

  has_many :primary_products, class_name: 'StoreProduct',
                              foreign_key: 'primary_image_id',
                              inverse_of: :primary_image,
                              dependent: :nullify

  has_many :thumb_products, class_name: 'StoreProduct',
                            foreign_key: 'thumb_image_id',
                            inverse_of: :thumb_image,
                            dependent: :nullify

  has_and_belongs_to_many :product_variants

  after_create_commit :notify_store_product_create
  after_update_commit :notify_store_product_update
  after_destroy_commit :notify_store_product_destroy

  def notify_store_product_create
    if self.imageable_type == 'StoreProduct'
      store_product = StoreProduct.find(self.imageable_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_update
    relevant_fields = ['url', 'imageable_type', 'imageable_id']
    changed_fields = self.previous_changes.keys & relevant_fields
    if self.imageable_type == 'StoreProduct' && changed_fields.any?
      store_product = StoreProduct.find(self.imageable_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    if self.imageable_type == 'StoreProduct' && self.imageable_id
      store_product = StoreProduct.find_by(id: self.imageable_id)
      if store_product
        # update store product last_updated_websocket with current time
        store_product.update(last_updated_websocket: Time.current)
      end
    end
  end
end

# == Schema Information
#
# Table name: images
#
#  id             :bigint           not null, primary key
#  imageable_type :string
#  url            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  imageable_id   :bigint
#
# Indexes
#
#  index_images_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#
