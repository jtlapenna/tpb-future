class KioskProductSerializer < ActiveModel::Serializer
  attributes :id, :featured

  belongs_to :store_product

  has_one :store, serializer: StoreMinimalSerializer
end
