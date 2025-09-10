class AdConfigSerializer < ActiveModel::Serializer
  attributes :id, :name, :use_brand_spotlight, :kiosk_id, :kiosk_product_id, :brand_id

  attribute :kiosk_product_stock do
    @object.kiosk_product&.stock
  end
  attribute :kiosk_product_name do    
    @object.kiosk_product&.name_for_catalog    
  end

  belongs_to :kiosk    
  belongs_to :kiosk_product
  belongs_to :brand
  belongs_to :store_product
  has_one :asset
end
