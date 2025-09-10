class ProductVariant < ApplicationRecord
  acts_as_taggable
  include AlgoliaSearch
  include Reviewable

  algoliasearch per_environment: true,
                auto_index: false, auto_remove: false,
                disable_indexing: proc {
                  Rails.env.test? || ENV['ALGOLIASEARCH_DISABLED'] == 'true'
                } do
    attribute :description do
      description_for_product
    end

    attribute :name do
      name_for_product
    end

    attribute :category do
      { name: category.name, id: category.id }
    end

    searchableAttributes ['name', 'category.name', 'unordered(description)']
  end

  belongs_to :product
  belongs_to :brand, optional: true

  has_many :attribute_values, as: :target, inverse_of: :target, dependent: :nullify
  accepts_nested_attributes_for :attribute_values, allow_destroy: true, reject_if: :all_blank

  has_many :attribute_defs, through: :attribute_values

  has_many :store_products, dependent: :nullify

  has_one :video, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :video, allow_destroy: true, reject_if: :all_blank

  has_and_belongs_to_many :images,
                          before_add: :check_image_owner,
                          after_add: :track_images_changes,
                          after_remove: :track_image_destroy

  delegate :name,
           :description,
           :video,
           :attribute_values,
           prefix: 'product',
           to: :product,
           allow_nil: true
  delegate :name, prefix: 'brand', to: :brand, allow_nil: true
  delegate :category, to: :product, allow_nil: true

  scope :name_like, lambda { |name|
    query = 'product_variants.name ILIKE :name OR '
    query += '(product_variants.name IS NULL AND products.name ILIKE :name)'

    joins(:product).where(query, name: "%#{name}%")
  }

  before_validation :sanitize_override_tags
  before_create :assign_default_image
  before_save :nilify_blank_attributes
  # This is to track tags changes and update updated_at
  before_save :track_tags_changes

  after_update :update_kiosk_products, if: :saved_change_to_brand_id?

  validates :sku, uniqueness: true, allow_nil: true

  def merged_attribute_values
    variant_values = attribute_values.includes(attribute_def: :attribute_group)
    product_values = product.attribute_values.includes(attribute_def: :attribute_group)
    (product.attribute_defs + attribute_defs).uniq.map do |a_def|
      find_value(variant_values, a_def) || find_value(product_values, a_def)
    end
  end

  def name_for_product
    name || product_name
  end

  def description_for_product
    description || product_description
  end

  # Prevent algolia reindex every save
  def will_save_change_to_category?
    false
  end

  def video_url
    video&.url
  end

  private

  def sanitize_override_tags
    self.override_tags = false unless override_tags
  end

  def nilify_blank_attributes
    self.name = nil if name.blank?
  end

  def check_image_owner(image)
    allowed_ids = product.image_ids

    raise 'Only images from parent product are allowed' unless allowed_ids.include?(image.id)
  end

  def assign_default_image
    return if !product || product.images.empty? || images.present?

    images << product.images.first
  end

  def find_value(values, definition)
    values.detect { |value| value.attribute_def_id == definition.id }
  end

  def track_tags_changes
    new_tags = tag_list.sort
    old_tags = tags.map(&:name).sort

    self.updated_at = Time.zone.now if persisted? && new_tags != old_tags
  end

  def track_images_changes(_image)
    self.updated_at = Time.zone.now
  end

  def track_image_destroy(image)
    track_images_changes(image)

    # Remove images from store products
    store_products.each do |cp|
      old_ids = cp.image_ids

      cp.update!(image_ids: old_ids - [image.id]) if old_ids.include?(image.id)
    end
  end

  def update_kiosk_products
    kiosk_was_scope = Kiosk.product_filter_criteria_brand.where(
      product_filter_value_type: 'Brand',
      product_filter_value_id: brand_id_before_last_save
    )
    store_product_scope = store_products.where(brand_id: nil)

    # Remove from kiosk with previous brand
    KioskProduct.joins(:kiosk, :store_product)
                .merge(kiosk_was_scope)
                .merge(store_product_scope)
                .find_each(&:destroy)

    # Add to new kiosks
    store_product_scope.find_each do |sp|
      sp.store
        .kiosks
        .product_filter_criteria_brand
        .where(product_filter_value: brand).find_each do |kiosk|
          kiosk.kiosk_products.create!(store_product: sp)
        end
    end
  end
end

# == Schema Information
#
# Table name: product_variants
#
#  id            :bigint           not null, primary key
#  description   :string
#  name          :string
#  override_tags :boolean          default(FALSE)
#  sku           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  brand_id      :bigint
#  product_id    :bigint
#
# Indexes
#
#  index_product_variants_on_brand_id    (brand_id)
#  index_product_variants_on_product_id  (product_id)
#  index_product_variants_on_sku         (sku) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id)
#  fk_rails_...  (product_id => products.id)
#
