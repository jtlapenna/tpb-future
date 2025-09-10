class StoreSync < ApplicationRecord
  enum status: {pending: 0, in_progress: 1, finished: 2}

  belongs_to :store

  has_many :store_sync_items, dependent: :destroy

  after_validation :try_to_finish, on: :update

  scope :owner, lambda { |owner|
    # WARNING: do not user merge on Catalog.owner
    joins(store: {client: :users})
        .merge(User.where(id: owner))
  }

  def process_items
    store_sync_items.pending.each do |csi|
      begin
        new_state = :unmatched!

        if csi.sku
          Rails.logger.info("Searching for CSI #{csi.sku}")
          # Check if there are two products created with the same sku
          same_product_ids = store.store_products.where(sku: csi.sku).order({created_at: :desc}).ids
          if same_product_ids.size > 1
            Rails.logger.warn("More that one record of the same product!!! #{csi.sku} -- #{same_product_ids} ")
            # Let's delete one of them [EXPERIMENTAL]
            # StoreProduct.destroy(same_product_ids[0])
          end
          if (cp = store.store_products.find_by(sku: csi.sku))
            Rails.logger.info("Found #{cp.sku}  -- #{cp.name} -- STORE ID #{cp.store_id} -- ")
            prices = (csi.prices || []).map do |p|
              current_price = cp.product_values.find_by(name: p['name'])
              id = current_price ? current_price.id : nil
              {name: p['name'], value: p['value'], id: id}
            end

            prices_to_destroy = cp.product_values
                                    .reject { |pv| prices.any? { |p| p[:id] == pv.id } }
                                    .map { |pv| {id: pv.id, _destroy: true} }

            attrs = {
                stock: csi.deactivated_item? ? 0 : csi.stock,
                product_values_attributes: prices + prices_to_destroy,
                latest_update_source: 'sync_job'
            }

            if store.override_on_sync
              attrs[:name] = csi.name || cp.name
              attrs[:description] = csi.description || cp.description
              if store.preserve_category
                attrs[:store_category] = cp.store_category
              else
                attrs[:store_category] = find_category(csi.category, force_downcase: true) || cp.store_category
              end

              attrs[:brand] = csi.find_brand || cp.brand
              attrs[:weight] = csi.weight || cp.weight
              if csi.images
                if csi.images['primary'].present?
                  # only update primary, thumb image if modified on integration types(treez, shopify etc)
                  alter_primary_image = false
                  own_image = cp.own_images.find_by(url: csi.images['primary'])

                  if own_image
                    alter_primary_image = true if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || cp.primary_image_id != own_image.id
                  else
                    alter_primary_image = true
                  end
                  alter_primary_image = true if store.api_type_leaflogix? || store.api_type_covasoft? || store.api_type_blaze? || store.api_type_flowhub? #bail_out treez
                  csi.images['all_images'] = csi.images['all_images'] || []
                  if alter_primary_image
                    csi.images['all_images'] << csi.images['primary']
                    cp.primary_image_url = csi.images['primary']
                    cp.thumb_image_url = csi.images['primary']
                  end
                end

                if csi.images['thumb'].present? && csi.images['primary'] != csi.images['thumb']
                  # only update thumb image if modified on integration types(treez, shopify etc)
                  alter_thumb_image = false
                  own_image = cp.own_images.find_by(url: csi.images['thumb'])

                  if own_image
                    alter_thumb_image = true if cp.thumb_image_id.nil? || cp.thumb_image_id != own_image.id
                  else
                    alter_thumb_image = true
                  end

                  if alter_thumb_image
                    csi.images['all_images'] << csi.images['thumb']
                    cp.thumb_image_url = csi.images['thumb']
                  end
                end

                images = (csi.images['all_images']&.uniq || []).map do |image_url|
                  own_image = cp.own_images.find_by(url: image_url)
                  id = own_image ? own_image.id : nil
                  {url: image_url, id: id}
                end

                own_images_to_destroy = cp.own_images.reject { |pv| images.any? { |p| p[:id] == pv.id } }.map { |pv| {id: pv.id, _destroy: true} }

                attrs[:own_images_attributes] = images + own_images_to_destroy

                if cp.primary_image_url.blank? && csi.images['all_images'].present?
                  # Image will be deleted when cp save, until then primary_image_id will be present
                  assign_img = own_images_to_destroy.any?{|item| (item[:id] == cp.primary_image_id || item[:id] == cp.thumb_image_id) }

                  if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || assign_img
                    cp.primary_image_url = csi.images['all_images'].first
                    cp.thumb_image_url = csi.images['all_images'].first
                  end
                end
              end

              attributes_values = (csi.attributes_values || []).map do |csi_attr|
                if (attr_value = cp.attribute_values.with_name(csi_attr['name']).first)
                  # Performance: skip attribute when value has not changed
                  unless attr_value.value.casecmp?(csi_attr['value'])
                    # Restrict values to definition (when attribute is restricted)
                    value = find_attr_value(attr_value.attribute_def, csi_attr['value'])
                    # update or destroy existing records
                    {id: attr_value.id, value: value, _destroy: value.blank?}
                  end
                elsif csi_attr['value'].present?
                  # Create new records
                  att_def = AttributeDef.by_name(csi_attr['name']).first
                  value = find_attr_value(att_def, csi_attr['value'])
                  if att_def.present? && value.present?
                    {id: nil, attribute_def_id: att_def.id, value: value}
                  end
                end
              end.compact

              attrs[:attribute_values_attributes] = attributes_values
              attrs[:inventory_type_medical] = csi.inventory_type_medical
              attrs[:is_medical_only] = csi.is_medical_only

              if (store.sync_tags)
                attrs[:tag_list] = csi.tags.present? ? csi.tags : []
              end
            end
            Rails.logger.info("Trying to validate and update #{cp.id} -- #{cp.sku}")
            if cp.validate!
              cp.update!(attrs)
              Rails.logger.info("Product saved #{attrs} -- CP ID #{cp.id}")
              csi.store_product_id = cp.id
              Rails.logger.info("Store product automatched #{cp.sku}")
              new_state = :auto_matched!
            else
              Rails.logger.error("Product failed to save #{attrs} -- CP ID #{cp.id}")
              Rails.logger.error("Errors #{cp.errors.full_messages}")
            end
          elsif csi.deactivated_item?
            new_state = :discarded!
          elsif store.api_automatch
            if (category = find_category(csi.category, force_downcase: true) ||
                store.store_categories.first)
              csi.store_category_id = category.id
            end
            csi.product_variant_id = ENV['WILDCARD_VARIANT_ID']
            csi.create_wildcard_product!

            new_state = :auto_confirmed!
          elsif csi.name && similar_products?(csi.name)
            new_state = :to_confirm!
          end
        else
          Rails.logger.warn("Product without SKU #{csi}")
        end
        Rails.logger.info("Product parsed #{csi.sku} -- Status #{new_state}")

        # Update item status
        csi.send(new_state)

        save!
      rescue StandardError => e
        puts e.message
        Rails.logger.error("Error processing #{csi.sku} -- #{e.message}")
        Sentry.capture_exception(e)
      end
    end
  end

  private

  def find_brand(brand_name)
    return if brand_name.blank?

    Brand.name_equal(brand_name).first
  end

  def find_category(category_name, force_downcase: false)
    return if category_name.blank?

    store.store_categories.name_lower(category_name).first ||
        store.store_categories.create(name: force_downcase ? category_name.downcase : category_name)
  end

  def try_to_finish
    self.status = :finished if store_sync_items.to_confirm.count.zero? &&
        store_sync_items.unmatched.count.zero?
  end

  def similar_products?(name)
    Product.name_like(name).exists?
  end

  def find_attr_value(attr_def, value)
    return value if attr_def.blank? || !attr_def.restricted?

    attr_def.values.detect { |v| v.casecmp?(value) }
  end
end

# == Schema Information
#
# Table name: store_syncs
#
#  id         :bigint           not null, primary key
#  status     :integer          default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  store_id   :bigint
#
# Indexes
#
#  index_store_syncs_on_store_id  (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
