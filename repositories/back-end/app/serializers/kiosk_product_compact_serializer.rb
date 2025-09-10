class KioskProductCompactSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :store_product do
    { id: object.store_product_id }
  end
end
