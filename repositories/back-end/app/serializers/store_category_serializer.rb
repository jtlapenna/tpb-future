class StoreCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :order, :store_id

  belongs_to :store, serializer: StoreMinimalSerializer
  has_one :banner
  has_many :store_category_taxes

end
