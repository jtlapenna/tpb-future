module Api
  module V1
    class StoreArticleSerializer < ActiveModel::Serializer
      type 'article'

      attributes :id, :store_id, :article_id, :text, :tag,
                 :title, :icon, :excerpt, :created_at, :updated_at

      belongs_to :category, serializer: Api::V1::CategorySerializer

      attribute :products do
        scope = object.products_for_catalog
        if minimal?
          scope.pluck(:id)
        else
          scope.includes(store_product_includes)
               .preload(store_product_preloads).order(id: :asc).map do |p|
            Api::V1::StoreProductSerializer.new(p).as_json(
              include: [
                'catalog_category', 'brand.logo', 'images', 'primary_image', 'product_values',
                'thumb_image', 'video'
              ]
            )
          end
        end
      end

      private

      def store_product_includes
        [
          { store_category: :store },
          { product_variant: { brand: :logo } },
          { brand: :logo },
          :product_values,
          :images,
          :primary_image,
          :thumb_image,
          :own_images
        ]
      end

      def store_product_preloads
        [
          { product_variant: [{ product: %i[tags video] }, :tags, :video] },
          :tags,
          :video
        ]
      end

      def minimal?
        instance_options[:minimal]
      end
    end
  end
end
