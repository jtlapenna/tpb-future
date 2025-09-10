class StoreSyncItem < ApplicationRecord
  belongs_to :store_sync

  enum status: {
      pending: 0,
      confirmed: 1,
      discarded: 2,
      auto_matched: 3,
      to_confirm: 4,
      unmatched: 5,
      auto_confirmed: 6
  }

  delegate :store, to: :store_sync

  store :fields, accessors: %i[
    sku name size_name weight category stock store_product_id
    store_category_id product_variant_id prices brand active
    description images tags attributes_values is_medical_only
  ], coder: JSON

  validates :sku, :stock, presence: true
  validates :stock, numericality: {greater_than_or_equal_to: 0}, if: :stock

  def create_store_product!
    create_product!

    confirmed!
  end

  def create_wildcard_product!
    create_product!
  end

  def update_store_product!
    self.prices ||= []
    self.attributes_values ||= []

    attributes_for_values = self.attributes_values.map do |attr|
      att_def = AttributeDef.by_name(attr['name']).first
      next if att_def.blank?

      att_value = find_attr_value(att_def, attr['value'])
      next if att_value.blank?

      AttributeValue.new(
        attribute_def: att_def, value: att_value
      )
    end.compact

    store.store_products
        .find_by!(product_variant_id: product_variant_id, id: store_product_id)
        .update!(
          stock: deactivated_item? ? 0 : stock,
          sku: sku,
          brand: find_brand,
          is_medical_only: self.is_medical_only,
          store_category: store_category,
          attribute_values: attributes_for_values,
          product_values_attributes: self.prices
                                         .map { |p| {name: p['name'], value: p['value']} }
        )

    confirmed!
  end

  def deactivated_item?
    store.api_type_treez? && !active
  end

  def find_brand
    return nil if brand.blank?

    found_brand = Brand.name_equal(brand).first

    found_brand = Brand.create(name: brand) if !found_brand && store.api_automatch

    found_brand
  end

  private

  def create_product!
    self.prices ||= []
    self.images ||= {}
    self.attributes_values ||= []
    image_values = self.images.values

    primary_image_url = self.images['primary'].presence
    thumb_image_url = self.images['thumb'].presence
    primary_image_url = image_values.first if primary_image_url.blank? && image_values.present?
    thumb_image_url = image_values.first if thumb_image_url.blank? && image_values.present?
    thumb_image_url = nil if primary_image_url == thumb_image_url

    attributes_for_values = self.attributes_values.map do |attr|
      att_def = AttributeDef.by_name(attr['name']).first
      next if att_def.blank?

      att_value = find_attr_value(att_def, attr['value'])
      next if att_value.blank?

      AttributeValue.new(
        attribute_def: att_def, value: att_value
      )
    end.compact

    begin
      # first_or_create to avoid creation of two products with the same sku
      # on the same category
      store_category.store_products.where(sku: sku).first_or_create!(
        store_category: store_category,
        brand: find_brand,
        product_variant: variant,
        stock: stock,
        sku: sku,
        weight: weight,
        name: name,
        description: description,
        latest_update_source: 'sync_job',
        product_values_attributes: self.prices.map { |p| {name: p['name'], value: p['value']} },
        own_images_attributes: image_values.map { |url| {url: url} }.uniq,
        primary_image_url: primary_image_url,
        thumb_image_url: thumb_image_url || primary_image_url,
        tag_list: store.sync_tags ? tags || [] : [],
        attribute_values: attributes_for_values,
        is_medical_only: self.is_medical_only
      )
    rescue StandardError => e
      Rails.logger.warn("Error creating store products for a store:: #{store.id} -- SKU #{sku} -- PRICES #{self.prices} -- CAUSE: #{e.message}")
      Rails.logger.warn(e.backtrace.inspect)
    end

  end

  def store_category
    StoreCategory.find(store_category_id)
  end

  def variant
    Rails.logger.info("Searching product variant #{product_variant_id}")
    ProductVariant.find(product_variant_id)
  end

  def find_attr_value(attr_def, value)
    return value unless attr_def.restricted?

    attr_def.values.detect { |v| v.casecmp?(value) }
  end
end

# == Schema Information
#
# Table name: store_sync_items
#
#  id                     :bigint           not null, primary key
#  fields                 :text
#  inventory_type_medical :boolean          default(FALSE)
#  status                 :integer          default("pending")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  store_sync_id          :bigint
#
# Indexes
#
#  index_store_sync_items_on_store_sync_id  (store_sync_id)
#  store_sync_items_created_at_index        (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (store_sync_id => store_syncs.id)
#
