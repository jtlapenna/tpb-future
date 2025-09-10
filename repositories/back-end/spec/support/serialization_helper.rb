module SerializationHelper
  module Stores
    def kiosk_product_compact_json(product)
      {
        id: product.id,
        store_product: {
          id: product.store_product_id
        }
      }.as_json
    end

    def kiosk_product_minimal_json(product)
      includes = {
        only: %i[id name sku stock status],
        include: {
          brand: { only: %i[id name] },
          store_category: { only: %i[id name] },
          thumb_image: { only: %i[id url] },
          product_variant: {
            only: %i[id name product_id],
            include: { brand: { only: %i[id name] } }
          }
        }
      }

      p_json = product.store_product.as_json(includes)
      p_json['brand'] = nil unless p_json['brand']
      p_json['store_category'] = nil unless p_json['store_category']
      p_json['thumb_image'] = nil unless p_json['thumb_image']

      product.as_json(only: %i[id featured]).merge('store_product' => p_json)
    end

    def kiosk_product_json(product)
      sp_json = store_product_json(product.store_product)
      product.as_json(only: %i[id featured]).merge('store_product' => sp_json)
    end

    def asset_json(asset)
      return nil unless asset

      asset.as_json(only: %i[id url])
    end

    def client_json(client)
      client.as_json(only: %i[id name])
    end

    def settings_json(settings, full: true)
      methods = %i[printer_location main_color secondary_color
                   featured_products_on_top_for_brands_page
                   featured_products_on_top_for_effects_and_uses_page
                   featured_products_on_top_for_products_page
                   default_product_description dispensary_license_number disable_tax_message]

      if full
        methods += %i[
          admin_email pos_location idle_delay restart_delay service_worker_log heap_id
        ]
      end

      settings.as_json(only: [:id], methods: methods).merge(
        'background_media' => asset_json(settings.background_media),
        'purchase_limits' => settings.purchase_limits.map { |limit| purchase_limit_json(limit) }
      )
    end

    def purchase_limit_json(limit)
      limit.as_json(only: %(id name limit store_category_ids))
    end

    def layout_json(layout)
      layout.as_json(
        only: %i[id template home_layout product_layout_id stand_side
                 welcome_message rfid_disabled shopping_disabled screen_type]
      )
    end

    def store_product_json(product)
      includes = {
        product_variant: {
          only: %i[id name sku description override_tags], methods: [:tag_list],
          include: {
            brand: { only: %i[id name description] },
            product: { only: %i[id name] },
            video: { only: %i[id url] }
          }
        },
        video: { only: %i[id url] },
        store_category: { only: %i[id name order store_id] },
        primary_image: { only: %i[id url] },
        thumb_image: { only: %i[id url] },
        own_images: { only: %i[id url] }
      }
      p_json = product.as_json(
        only: %i[
          id sku name description share_email_template
          share_sms_template stock override_tags featured status weight
        ],
        include: includes,
        methods: [:tag_list]
      )

      p_json['video'] = nil unless p_json['video']
      p_json['tag_list'].sort!
      p_json['store'] = product.store.as_json(only: %i[id name])
      p_json['brand'] = product.brand.as_json(only: %i[id name description])
      p_json['attribute_values'] = product.attribute_values.map do |attr_val|
        val_json = attr_val.as_json(
          only: %i[id value], include: { attribute_def: {
            only: %i[id name restricted values], include: { attribute_group: {
              only: %i[id name group_type order]
            } }
          } }
        )
        val_json
      end

      p_json['product_variant']['attribute_values'] = []
      p_json['product_variant']['video'] = nil unless p_json['product_variant']['video']
      p_json['product_variant']['is_wildcard'] =
        product.product_variant_id == ENV['WILDCARD_VARIANT_ID'].to_i

      p_json['product_values'] = product.product_values.map do |pv|
        { id: pv.id, name: pv.name, value: pv.value.to_f.to_s }.stringify_keys
      end
      p_json['images'] = product.images.map do |image|
        image.as_json(:id, :url)
      end
      p_json['primary_image'] = nil unless p_json['primary_image']
      p_json['thumb_image'] = nil unless p_json['thumb_image']
      p_json['product_variant']['images'] = product.product_variant.images.as_json(only: %i[id url])

      p_json
    end
  end
end
