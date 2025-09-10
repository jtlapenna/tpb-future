class StoreProductMinimalSerializer < ActiveModel::Serializer
  attributes :id, :name, :sku, :stock, :status

  belongs_to :brand, serializer: BrandMinimalSerializer

  belongs_to :product_variant, serializer: ProductVariantMinimalSerializer

  belongs_to :store_category, serializer: StoreCategoryMinimalSerializer

  belongs_to :thumb_image

  has_one :store, serializer: StoreMinimalSerializer
end
