module Api::V1::SerializationHelper
  module Products
    def kiosk_product_json(product, include_attribute_values: false, include_layout: false)
      k_json = product_json(
        product.store_product, include_attribute_values: include_attribute_values
      )
      k_json['layout'] = kiosk_product_layout_json(product) if include_layout
      k_json.merge(
        'rfids' => product.rfids,
        'featured' => product.featured_product?,
        'created_at' => product.created_at.iso8601(3),
        'updated_at' => [
          product,
          product.store_product,
          product.store_product.product_variant,
          product.store_product.product
        ].map(&:updated_at).max.iso8601(3)
      )
    end

    def product_json(product, include_attribute_values: false)
      image_includes = { only: %i[id url] }

      includes = {
        store_category: { only: %i[id name] },
        images: image_includes,
        primary_image: image_includes,
        thumb_image: image_includes
      }

      p_json = product.as_json(
        only: %i[id sku name tags description stock],
        methods: [:tag_list],
        include: includes
      ).tap do |json|
        json['product_values'] = product.product_values.order(:id).map do |pv|
          {
            id: pv.id,
            name: pv.name,
            value: pv.value.to_f.to_s,
            created_at: pv.created_at.iso8601(3),
            updated_at: pv.updated_at.iso8601(3)
          }.stringify_keys
        end
        json['primary_image'] = nil unless json['primary_image']
        json['thumb_image'] = nil unless json['thumb_image']
        json['attribute_values'] = {} if include_attribute_values
      end.merge(
        'created_at' => product.created_at.iso8601(3),
        'updated_at' => product.updated_at.iso8601(3)
      )

      p_json['video'] = nil
      p_json['video_url'] = nil
      if video = product.video_for_catalog
        p_json['video_url'] = video.url
        p_json['video'] = video.as_json(only: %i[id url])
                               .merge(
                                 'created_at' => video.created_at.iso8601(3),
                                 'updated_at' => video.updated_at.iso8601(3)
                               )
      end
      if product.store_category
        p_json['catalog_category'] = p_json.delete('store_category')
        p_json['catalog_category']['created_at'] = product.store_category.created_at.iso8601(3)
        p_json['catalog_category']['updated_at'] = product.store_category.updated_at.iso8601(3)
      end
      if product.brand_for_catalog
        p_json['brand'] = product.brand_for_catalog
                                 .as_json(only: %i[id name], include: { logo: image_includes })
        p_json['brand']['created_at'] = product.brand_for_catalog.created_at.iso8601(3)
        p_json['brand']['updated_at'] = product.brand_for_catalog.updated_at.iso8601(3)
        p_json['brand']['created_at'] = product.brand_for_catalog.created_at.iso8601(3)
        if product.brand_for_catalog.logo
          p_json['brand']['logo']['updated_at'] = product.brand_for_catalog.logo.updated_at.iso8601(3)
          p_json['brand']['logo']['created_at'] = product.brand_for_catalog.logo.created_at.iso8601(3)
        else
          p_json['brand']['logo'] = nil
        end
      end
      if product.primary_image
        p_json['primary_image']['created_at'] = product.primary_image.created_at.iso8601(3)
        p_json['primary_image']['updated_at'] = product.primary_image.updated_at.iso8601(3)
      end
      if product.thumb_image
        p_json['thumb_image']['created_at'] = product.thumb_image.created_at.iso8601(3)
        p_json['thumb_image']['updated_at'] = product.thumb_image.updated_at.iso8601(3)
      end

      p_json['tag_list'] = product.products_tags.sort

      p_json['images'] = (product.images + product.own_images).map do |image|
        image.as_json(only: %i[id url]).merge(
          'created_at' => image.created_at.iso8601(3),
          'updated_at' => image.updated_at.iso8601(3)
        )
      end

      p_json
    end

    def kiosk_product_layout_json(product)
      layout = product.kiosk.product_layout
      return if layout.blank?

      values = product.product_layout_values

      return if values.blank?

      grouped_values = values.group_by(&:element_source).to_a

      common = grouped_values
               .select { |source, _| source == layout }
               .flat_map(&:second)

      tabs = grouped_values
             .select { |source, _| source.is_a?(ProductLayoutTab) && source.product_layout_id == layout.id }
             .sort_by { |tab, _element| tab.order }

      {
        common: product_layout_common_json(common),
        tabs: tabs.map { |tab, _elements| product_layout_tab_json(tab, values) }
      }
    end

    def product_layout_common_json(values = [])
      {
        media: values.select(&:element_medium?).map { |value| product_layout_value_json(value) },
        dots: values.select(&:element_dot?).map { |value| product_layout_value_json(value) },
        texts: values.select(&:element_text?).map { |value| product_layout_value_json(value) }
      }
    end

    def product_layout_tab_json(tab, values = [])
      {
        name: tab.name,
        media: values.select(&:element_medium?).map { |value| product_layout_value_json(value) },
        dots: values.select(&:element_dot?).map { |value| product_layout_value_json(value) },
        texts: values.select(&:element_text?).map { |value| product_layout_value_json(value) }
      }
    end

    def product_layout_value_json(value)
      json = {
        coord_x: value.coord_x,
        coord_y: value.coord_y
      }

      json[:link] = value.link unless value.element_text?
      json[:content] = value.content if value.element_text?
      json[:asset] = Stores.asset_json(value.asset) if value.element_medium?
      json[:width] = value.width unless value.element_dot?

      json
    end
  end

  module Stores
    def asset_json(asset)
      return nil unless asset

      a_json = asset.as_json(only: %i[id url])
      a_json['created_at'] = asset.created_at.iso8601(3)
      a_json['updated_at'] = asset.updated_at.iso8601(3)
      a_json
    end
    module_function :asset_json

    def store_json(store)
      methods = %i[admin_email printer_location pos_location main_color secondary_color
                   featured_products_on_top_for_brands_page featured_products_on_top_for_effects_and_uses_page
                   featured_products_on_top_for_products_page idle_delay restart_delay service_worker_log
                   default_product_description heap_id dispensary_license_number disable_tax_message]

      includes = {
        # layout: { only: [:id, :template, :home_layout, :welcome_message, :rfid_disabled, :shopping_disabled], include: {
        #   welcome_asset: { only: [:id], include: { asset: { only: [:id, :url] } } },
        #   navigation: { only: [:id] }
        # }},
        settings: { only: [], methods: methods }
      }
      s_json = store.as_json(only: %i[id name], include: includes).merge(
        'created_at' => store.created_at.iso8601(3),
        'updated_at' => store.updated_at.iso8601(3)
      )

      s_json['settings']['background_media'] = asset_json(store.settings.background_media)

      # s_json["layout"]["store_assets"] = store.layout.store_assets.map do |sa|
      #   { "id" => sa.id, "text" => sa.text, "secondary_text" => sa.secondary_text, code: sa.code,
      #     "text_position" => sa.text_position.label, "asset_position" => sa.asset_position.label,
      #     "section_position" => sa.section_position.label,
      #     "created_at" => sa.created_at.iso8601(3), "updated_at" => sa.updated_at.iso8601(3),
      #     "dots" => sa.asset_elements.select{|pip| pip.element_type == "dot"}.map do |ae|
      #       {
      #         "id" => ae.id, "link" => ae.link, "coord_x" => ae.coord_x, "coord_y" => ae.coord_y,
      #         "created_at" => ae.created_at.iso8601(3), "updated_at" => ae.updated_at.iso8601(3),
      #       }
      #     end,
      #     "pictures_in_pictures" => sa.asset_elements.select{|pip| pip.element_type == "picture_in_picture"}.map do |ae|
      #     !ae.asset ? nil : asset_json = { "id" => ae.asset.id, "url" => ae.asset.url, "created_at" => ae.asset.created_at.iso8601(3), "updated_at" => ae.asset.updated_at.iso8601(3) }
      #       {
      #         "id" => ae.id, "link" => ae.link, "coord_x" => ae.coord_x, "coord_y" => ae.coord_y,
      #         "created_at" => ae.created_at.iso8601(3), "updated_at" => ae.updated_at.iso8601(3), "asset" => asset_json,
      #       }
      #     end,
      #     "asset" => { "id" => sa.asset.id, "url" => sa.asset.url, "created_at" => sa.asset.created_at.iso8601(3), "updated_at" => sa.asset.updated_at.iso8601(3) }

      #   }.stringify_keys
      # end

      # s_json["layout"]["navigation"]["items"] = store.layout.navigation.items.map do |item|
      #   { "id" => item.id, "label" => item.label, "order" => item.order, "link" => item.link }.stringify_keys
      # end

      # if store.layout.welcome_asset && store.layout.welcome_asset.asset
      #   s_json["layout"]["welcome_asset"]["asset"]["created_at"] = store.layout.welcome_asset.asset.created_at.iso8601(3)
      #   s_json["layout"]["welcome_asset"]["asset"]["updated_at"] = store.layout.welcome_asset.asset.updated_at.iso8601(3)
      # end

      # if store.layout.welcome_asset
      #   s_json["layout"]["welcome_asset"]["asset_position"] = store.layout.welcome_asset.asset_position.label
      #   s_json["layout"]["welcome_asset"]["created_at"] = store.layout.welcome_asset.created_at.iso8601(3)
      #   s_json["layout"]["welcome_asset"]["updated_at"] = store.layout.welcome_asset.updated_at.iso8601(3)
      # else
      #   s_json["layout"]["welcome_asset"] = nil
      # end

      # s_json["layout"]["created_at"] = store.layout.created_at.iso8601(3)
      # s_json["layout"]["updated_at"] = store.layout.updated_at.iso8601(3)
      s_json['logo'] = asset_json(store.logo)

      s_json
    end
  end

  module Rfids
    def rfid_json(rfid_product)
      {
        'code' => rfid_product.rfid,
        'product_id' => rfid_product.rfid_entity_type == 'KioskProduct' ? rfid_product.rfid_entity.store_product_id : nil,
        'rfid_entity_id' => rfid_product.rfid_entity_id,
        'rfid_entity_type' => rfid_product.rfid_entity_type,
        'created_at' => rfid_product.created_at.iso8601(3),
        'updated_at' => rfid_product.updated_at.iso8601(3)

      }
    end
  end
end
