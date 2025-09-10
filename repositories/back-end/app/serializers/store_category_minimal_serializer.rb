class StoreCategoryMinimalSerializer < ActiveModel::Serializer
  attributes :id, :name
  belongs_to :store, serializer: StoreMinimalSerializer
  has_many :store_category_taxes
end
