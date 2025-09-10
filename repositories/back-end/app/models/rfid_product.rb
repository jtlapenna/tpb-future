class RfidProduct < ApplicationRecord  
  belongs_to :kiosk_product, class_name: 'KioskProduct',
                              primary_key: 'id',
                              foreign_key: 'rfid_entity_id',
                              optional: true
  has_one :store_product, :through => :kiosk_product
  belongs_to :kiosk, optional: true

  before_validation :denormalize_kiosk_id
  before_validation :rfid_to_uppercase
  
  has_paper_trail on: %i[update destroy], ignore: [:updated_at]
  

  belongs_to :rfid_entity, polymorphic: true, inverse_of: :rfid_products, touch: true, optional: true
  belongs_to :brand_and_store_category, foreign_key: :rfid_entity_id, optional: true
  validates :order, presence: true, numericality: { only_integer: true }

  validates :rfid, uniqueness: {scope: :kiosk_id, :message => "%{value}"}

  scope :owner, lambda { |owner|
    joins(:kiosk).merge(Kiosk.owner(owner))
  }

  scope :sorted, -> { order(id: :asc) }
  scope :sorted_by_availability, -> { includes(:store_product).order('store_products.stock=0 AND store_products.stock IS NOT NULL DESC, store_products.stock IS NULL DESC, rfid_products.created_at DESC') }

  after_update_commit :notify_store_product_update
  after_create_commit :notify_store_product_create
  after_destroy_commit :notify_store_product_destroy

  def notify_store_product_create
    if self.rfid_entity_type == 'KioskProduct'
      kiosk_product = KioskProduct.find(self.rfid_entity_id)
      store_product = StoreProduct.find(kiosk_product.store_product_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_update
    relevant_fields = ['rfid', 'rfid_entity_type', 'rfid_entity_id', 'order']
    changed_fields = self.previous_changes.keys & relevant_fields
    if self.rfid_entity_type == 'KioskProduct' && changed_fields.any?
      kiosk_product = KioskProduct.find(self.rfid_entity_id)
      store_product = StoreProduct.find(kiosk_product.store_product_id)
      # update store product last_updated_websocket with current time
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    if self.rfid_entity_type == 'KioskProduct' && self.rfid_entity_id
      kiosk_product = KioskProduct.find(self.rfid_entity_id)
      store_product = StoreProduct.find_by(id: kiosk_product.store_product_id)
      if store_product
        # update store product last_updated_websocket with current time
        store_product.update(last_updated_websocket: Time.current)
      end
    end
  end

  def kiosk_product_id
    rfid_entity_id if rfid_entity_type == KioskProduct.name
  end

  private

  def denormalize_kiosk_id
    return unless rfid_entity && rfid_entity_type == KioskProduct.name

    self.kiosk_id = rfid_entity.kiosk_id
  end

  def rfid_to_uppercase
    self.rfid = rfid.upcase if rfid
  end
end

# == Schema Information
#
# Table name: rfid_products
#
#  id               :bigint           not null, primary key
#  order            :integer          default(0)
#  rfid             :string
#  rfid_entity_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  kiosk_id         :bigint
#  rfid_entity_id   :bigint
#
# Indexes
#
#  index_rfid_products_on_kiosk_id                             (kiosk_id)
#  index_rfid_products_on_rfid_entity_type_and_rfid_entity_id  (rfid_entity_type,rfid_entity_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_id => kiosks.id)
#
