class ProductVariantMinimalSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_id

  belongs_to :brand, serializer: BrandMinimalSerializer

  def name
    object.name || object.product.name
  end
end
