module Api
  module V1
    class KioskProductSerializer < ActiveModel::Serializer
      belongs_to :brand_for_catalog, key: :brand, serializer: Api::V1::BrandMinimalSerializer
      belongs_to :store_category, key: :catalog_category,
                                  serializer: Api::V1::StoreCategoryMinimalSerializer
      belongs_to :primary_image
      belongs_to :thumb_image

      has_many :product_values
      has_many :images do
        object.store_product.images + object.store_product.own_images
      end
      has_many :store_product_promotions do
        object.store_product.store_product_promotions
      end
      attribute :category_taxes do
        object.store_category_taxes
      end

      attribute :store_taxes do
        object.store_taxes
      end


      attribute :id do
        @object.store_product_id
      end

      attribute :video_url do
        object.video_for_catalog&.url
      end

      attribute :is_medical_only do
        object.store_product.is_medical_only
      end

      attribute :is_full_screen do
        object.store_product.is_full_screen
      end

      attribute :created_at do
        @object.created_at
      end

      attribute :updated_at do
        st_product = object.store_product
        [
          object.updated_at, st_product.updated_at,
          st_product.product_variant.updated_at,
          st_product.product.updated_at
        ].max
      end

      attribute :attribute_values, if: :include_attribute_values? do
        sp = object.store_product

        group_by_attribute_values =
          sp.merged_attribute_values.group_by { |av| av.attribute_def.attribute_group }

        ungrouped, grouped = sp.merged_attribute_values.partition do |attr_value|
          attr_value.attribute_def.attribute_group.blank?
        end

        grouped = grouped.group_by { |av| av.attribute_def.attribute_group }

        {}.tap do |json|
          if ungrouped.present?
            json['ungrouped'] =
              CollectionSerializer.new(
                sort_by_name(ungrouped), serializer: Api::V1::AttributeValueSerializer
              )
          end

          if grouped.present?
            json['grouped'] = grouped.to_a.sort_by { |grp, _values| grp.order }.map do |grp, values|
              [
                grp.name,
                CollectionSerializer.new(values, serializer: Api::V1::AttributeValueSerializer)
              ]
            end.to_h
          end
        end
      end

      attribute :layout, if: :include_layout?

      attribute :featured_product?, key: :featured

      attribute :name_for_catalog, key: :name

      attribute :description_for_catalog, key: :description

      has_one :video_for_catalog, key: :video, serializer: Api::V1::AssetSerializer

      attributes :sku, :tag_list, :stock, :rfids, :status

      def include_attribute_values?
        instance_options[:include_attribute_values] == true
      end

      def include_layout?
        instance_options[:include_layout] == true
      end

      def tag_list
        object.products_tags.sort
      end

      def layout
        layout = object.kiosk.product_layout
        return if layout.blank?

        values = object.product_layout_values

        grouped_values = values.group_by(&:element_source).to_a

        common = grouped_values
                 .select { |source, _| source == layout }
                 .flat_map(&:second)

        tabs = grouped_values
               .select do |source, _|
                 source.is_a?(ProductLayoutTab) && source.product_layout_id == layout.id
               end
               .sort_by { |tab, _element| tab.order }

        return unless common.present? || tabs.present?

        {}.tap do |json|
          json['stylesheet'] = [layout.stylesheet, object.stylesheet].reject(&:blank?).join("\n")
          json['common'] = Api::V1::ProductLayoutValueContainerSerializer.new(
            {}, values: common || []
          )
          json['tabs'] = tabs.map do |tab, tab_values|
            Api::V1::ProductLayoutTabSerializer.new(
              tab, values: tab_values
            )
          end
        end
      end

      private

      def sort_by_name(values)
        values.sort_by { |value| value.attribute_def.name }
      end
    end
  end
end
