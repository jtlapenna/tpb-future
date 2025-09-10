class StoreMinimalSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :store_taxes
end
