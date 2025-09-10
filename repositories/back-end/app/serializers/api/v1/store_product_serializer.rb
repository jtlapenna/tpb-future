module Api
  module V1
    class StoreProductSerializer < ActiveModel::Serializer
      attributes :id, :sku, :tag_list, :stock, :created_at

      attribute :name_for_catalog, key: :name

      attribute :description_for_catalog, key: :description

      attribute :updated_at do
        [object.updated_at, object.product_variant.updated_at, object.product.updated_at].max
      end

      attribute :video_url do
        object.video_for_catalog&.url
      end

      belongs_to :store_category, key: :catalog_category,
                                  serializer: Api::V1::StoreCategoryMinimalSerializer
      belongs_to :brand_for_catalog, key: :brand, serializer: Api::V1::BrandMinimalSerializer
      belongs_to :primary_image
      belongs_to :thumb_image

      has_one :video_for_catalog, key: :video, serializer: Api::V1::AssetSerializer

      has_many :product_values
      has_many :images do
        object.images + object.own_images
      end

      def tag_list
        object.products_tags.sort
      end
    end
  end
end
