class Kiosk < ApplicationRecord
  acts_as_taggable

  enum product_filter_criteria: { custom: 0, all: 1, brand: 2, category: 3 },
       _prefix: :product_filter_criteria

  belongs_to :store

  belongs_to :product_filter_value, polymorphic: true, optional: true

  has_one :layout, class_name: 'KioskLayout', dependent: :destroy

  has_many :kiosk_products, dependent: :destroy
  has_many :store_products, through: :kiosk_products
  has_many :product_variants, through: :store_products
  has_many :store_categories, -> { merge(StoreProduct.published) }, through: :store_products

  has_many :rfid_products, dependent: :destroy
  accepts_nested_attributes_for :rfid_products, allow_destroy: true, reject_if: :all_blank

  has_many :ad_configs, dependent: :destroy

  has_many :expired_kiosk_products, dependent: :destroy

  store :data, accessors: %i[
    sensor_method sensor_threshold
  ], coder: JSON

  delegate :product_layout_id, :product_layout, to: :layout, allow_nil: true

  before_create :build_default_layout, unless: :layout

  after_create :auto_add_products!, unless: :product_filter_criteria_custom?
  after_update :auto_replace_products!, if: :product_filter_changed?

  validates :name, presence: true
  validates :rfid_sorting,  numericality: { only_integer: true }
  validates :rfid_behavior,  numericality: { only_integer: true }
  validates :sensor_method, inclusion: { in: %w[rfid us nfc], allow_blank: true }
  validates :sensor_threshold, numericality: { only_integer: true, allow_blank: true }

  scope :active, -> { where active: true }

  scope :owner, lambda { |owner|
    joins(:store)
      .merge(Store.owner(owner))
  }

  def brands
    joins = <<-SQL
      INNER JOIN (
        SELECT
          COALESCE(store_products.brand_id, product_variants.brand_id) as brand_id,
          COUNT(*) as kiosk_products_count,
          kiosk_products.kiosk_id as kiosk_id
        FROM store_products
        INNER JOIN kiosk_products ON kiosk_products.store_product_id = store_products.id
        INNER JOIN product_variants ON store_products.product_variant_id = product_variants.id
        WHERE store_products.status = #{StoreProduct.statuses['published']}
        GROUP BY
          COALESCE(store_products.brand_id, product_variants.brand_id),
          kiosk_products.kiosk_id
        HAVING
          SUM(store_products.stock) > 0
      ) product_brands ON product_brands.brand_id = brands.id
    SQL

    Brand.joins(joins)
         .where('product_brands.kiosk_id = :kiosk_id', kiosk_id: id)
         .distinct
  end

  def products_tags
    taggins = [ActsAsTaggableOn::Tag.for_object(self)]
    taggins << ActsAsTaggableOn::Tag.for_objects(store_products)
    taggins << ActsAsTaggableOn::Tag.for_objects(
      product_variants.where(store_products: { override_tags: false })
    )
    taggins << ActsAsTaggableOn::Tag.for_objects(
      product_variants.where(
        override_tags: false,
        store_products: { override_tags: false }
      ).map(&:product)
    )

    ActsAsTaggableOn::Tag.union_scope(*taggins)
  end

  private

  def build_default_layout
    build_layout
  end

  def product_filter_changed?
    saved_change_to_product_filter_criteria? ||
      saved_change_to_product_filter_value_id? ||
      saved_change_to_product_filter_value_type?
  end

  def auto_add_products!
    product_filter_scope.find_each do |sp|
      kiosk_products.create!(store_product: sp)
    end
  end

  def auto_replace_products!
    return if product_filter_criteria_custom?

    # Destroy products that don't match current scope
    kiosk_products.where.not(store_product_id: product_filter_scope).find_each(&:destroy)

    # Add products that match current scope
    product_filter_scope.where.not(id: kiosk_products.select(:store_product_id)).find_each do |sp|
      kiosk_products.create!(store_product: sp)
    end
  end

  def product_filter_scope
    case product_filter_criteria.to_sym
    when :all then store.store_products
    when :category then store.store_products.where(store_category: product_filter_value)
    when :brand then store.store_products.by_brand(product_filter_value)
    else StoreProduct.none
    end
  end
end

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: kiosks
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(TRUE)
#  data                      :text
#  location                  :string
#  name                      :string
#  product_filter_criteria   :integer          default("custom")
#  product_filter_value_type :string
#  rfid_behavior             :string           default("0")
#  rfid_sorting              :string           default("0")
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  product_filter_value_id   :bigint
#  store_id                  :integer
#
# Indexes
#
#  index_kiosks_on_product_filter_value  (product_filter_value_type,product_filter_value_id)
#  index_kiosks_on_store_id              (store_id)
#  index_kiosks_product_filter_criteria  (product_filter_criteria,product_filter_value_type,product_filter_value_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
