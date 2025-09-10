class KioskProductMinimalSerializer < ActiveModel::Serializer
  attributes :id, :featured

  belongs_to :store_product, serializer: StoreProductMinimalSerializer
  has_one :store, serializer: StoreMinimalSerializer

end
