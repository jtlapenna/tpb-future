class ProductLayoutValueSerializer < ActiveModel::Serializer
  attributes :id, :link, :content, :product_layout_element_id

  has_one :asset
end
