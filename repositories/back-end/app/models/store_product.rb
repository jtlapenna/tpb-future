class StoreProduct < ApplicationRecord
  include AlgoliaSearch
  include UnionScope

  attr_accessor :thumb_image_url
  attr_accessor :primary_image_url

  enum status: { unpublished: 0, published: 1 }

  algoliasearch per_environment: true,
                auto_index: false, auto_remove: false,
                disable_indexing: proc {
                  Rails.env.test? || ENV['ALGOLIASEARCH_DISABLED'] == 'true'
                } do
    attribute :store_id

    attribute :description do
      description_for_catalog
    end

    attribute :name do
      name_for_catalog
    end

    attribute :brand_id do
      brand_for_catalog&.id
    end

    attribute :store_category do
      { name: store_category.name, id: store_category.id }
    end

    attribute :product_id do
      product.id
    end

    numericAttributesToIndex [
      'equalOnly(store_id)', 'equalOnly(store_category.id)',
      'equalOnly(product_id)', 'equalOnly(brand_id)'
    ]

    searchableAttributes ['name', 'store_category.name', 'unordered(description)']
  end

  acts_as_taggable
  has_paper_trail on: %i[update destroy]

  belongs_to :store_category
  belongs_to :product_variant
  belongs_to :primary_image, class_name: 'Image', optional: true
  belongs_to :thumb_image, class_name: 'Image', optional: true
  belongs_to :brand, optional: true

    has_one :store, through: :store_category

  has_one :video, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :destroy
  accepts_nested_attributes_for :video, allow_destroy: true, reject_if: :all_blank

  has_many :attribute_values, as: :target, inverse_of: :target, dependent: :destroy
  accepts_nested_attributes_for :attribute_values, allow_destroy: true, reject_if: :all_blank

  has_many :attribute_defs, through: :attribute_values

  has_many :product_values, as: :valuable, inverse_of: :valuable, dependent: :destroy
  accepts_nested_attributes_for :product_values, allow_destroy: true, reject_if: :all_blank

  has_many :kiosk_products, dependent: :destroy
  has_many :duplicated_sku_deleted_logs, dependent: :destroy

  has_and_belongs_to_many :images,
                          before_add: :check_image_owner,
                          after_add: :track_images_changes,
                          after_remove: :track_image_destroy

  has_many :own_images, as: :imageable, inverse_of: :imageable, class_name: 'Image',
                        dependent: :destroy
  accepts_nested_attributes_for :own_images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :primary_image, allow_destroy: true, reject_if: :all_blank
  has_many :store_product_promotions
  has_and_belongs_to_many :store_articles

  delegate :product, to: :product_variant

  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: { scope: :store_id }
  validates :share_sms_template, length: { maximum: 160 }, if: :share_sms_template_changed?
  validates :weight, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validates :latest_update_source, inclusion: { in: %w[webhooks sync_job] }, allow_nil: true

  scope :by_tag_relevance, lambda { |tags|
    joins(sanitize_sql_array(["LEFT JOIN\
           ( SELECT distinct taggings.taggable_id, taggings.taggable_type from taggings\ WHERE
             EXISTS (SELECT 1 FROM tags WHERE tags.id = taggings.tag_id AND tags.name IN ( ? ))\
           ) AS tags ON tags.taggable_id = store_products.id\
           AND tags.taggable_type = 'StoreProduct'", tags]))
      .order(Arel.sql('CASE WHEN tags.taggable_id is NULL THEN 1 ELSE 0 END'))
  }
  scope :name_like, lambda { |name|
    query = <<-SQL
      store_products.name ILIKE :name OR
      (store_products.name IS NULL AND product_variants.name ILIKE :name) OR
      (store_products.name IS NULL AND product_variants.name IS NULL AND products.name ILIKE :name)
      OR brands.name ILIKE :name
    SQL

    joins(product_variant: :product).left_joins(:brand).where(query, name: "%#{name}%")
  }
  scope :by_brand, lambda { |brand_id|
    joins(:product_variant)
      .where(Arel.sql(
               'COALESCE(store_products.brand_id, product_variants.brand_id) = :brand_id'
             ), brand_id: brand_id)
  }
  scope :by_attribute_value, lambda { |attribute_value|
    joins(product_variant: :product)
      .joins(
        sanitize_sql_array(
          [
            "LEFT JOIN attribute_values attribute_values_product_variants ON
              attribute_values_product_variants.target_id = product_variants.id
              AND attribute_values_product_variants.target_type = ?
              AND attribute_values_product_variants.attribute_def_id = ?",
            'ProductVariant', attribute_value.attribute_def_id
          ]
        )
      ).joins(
        sanitize_sql_array(
          [
            "LEFT JOIN attribute_values attribute_values_products ON
              attribute_values_products.target_id = products.id
              AND attribute_values_products.target_type = ?
              AND attribute_values_products.attribute_def_id = ?",
            'Product', attribute_value.attribute_def_id
          ]
        )
      ).where(
        'LOWER(
          COALESCE(attribute_values_product_variants.value, attribute_values_products.value)
        ) = ?',
        attribute_value.value.to_s.downcase
      )
  }

  scope :price_in, lambda { |prices, tolerance:|
    ranges = prices.map { |price| price * (1 - tolerance)..price * (1 + tolerance) }

    prices_scope = ranges.map { |range| ProductValue.arel_table[:value].between(range) }
                         .reduce { |disjunction, price_scope| disjunction.or(price_scope) }

    joins(:product_values).where(prices_scope)
  }

  scope :similar_to, lambda { |product|
    scoped = where.not(id: product.id).where(store_id: product.store_id)

    product_type = product.attribute_value_by_name('type')

    # Rules 1: match products with the same category & type
    if product_type
      same_category_and_type = scoped.by_attribute_value(product_type)
                                     .where(store_category_id: product.store_category_id)
    end

    # Rule 2: match products with the same type & similar price (+/- 20%)
    if product_type && product.product_values.exists?
      same_price_and_type = scoped.by_attribute_value(product_type)
                                  .price_in(
                                    product.product_values.pluck(:value), tolerance: 0.2
                                  )
    end

    # Rule 3: match products with the same tags
    same_tag = scoped.joins(taggings: :tag).merge(ActsAsTaggableOn::Tag.where(id: product.tags))

    rules = [same_category_and_type, same_price_and_type, same_tag]

    joins = <<-SQL
      INNER JOIN #{similarity_table(rules)} as similar_store_products
      ON store_products.id = similar_store_products.id
    SQL

    scoped
      .joins(joins)
      .order('similar_store_products.rule_priority')
  }

  scope :owner, lambda { |owner|
    joins(:store).merge(Store.owner(owner))
  }

  scope :deep_tagged_with, lambda { |tag|
    store_products = default_scoped.tagged_with(tag)
    product_variants = default_scoped.where(override_tags: false)
                                     .joins(:product_variant)
                                     .merge(ProductVariant.tagged_with(tag))
    products = default_scoped
               .where(override_tags: false, product_variants: { override_tags: false })
               .joins(product_variant: :product)
               .merge(Product.tagged_with(tag))

    union_scope(store_products, product_variants, products)
  }

  scope :with_category_product, lambda { |category|
    joins(product_variant: :product).merge(Product.with_category(category))
  }

  scope :with_store_category, lambda { |category|
    merge(StoreCategory.name_equal(category.name))
  }
  scope :sku_like, -> (sku) { where("sku like '%#{sku}%'") }

  before_validation :denormalize_store_id
  before_validation :assign_default_image, on: :create
  before_validation :sanitize_override_tags
  before_validation :assign_images_by_url

  before_save :check_main_images_ownership
  before_save :assign_default_main_image
  before_save :nilify_blank_attributes
  # This is to track tags changes and update updated_at
  before_save :track_tags_changes

  after_create :create_kiosks_products
  after_update :update_kiosks_products

  after_update_commit :broadcast_changes_update
  before_destroy :broadcast_changes_destroy

  before_destroy :log_to_catch_rfid

  def self.similarity_table(rules)
    rules_sql = rules.compact.map.with_index do |rule_scope, index|
      rule_scope.select("store_products.id, #{index} as rule_priority").to_sql
    end

    rules_union = "(#{rules_sql.join(') UNION (')})"

    "(SELECT min(rule_priority) as rule_priority, id FROM (#{rules_union}) as similars GROUP BY id)"
  end

  def has_pusher_env
    if !ENV['PUSHER_APP_ID'] || !ENV['PUSHER_KEY'] || !ENV['PUSHER_SECRET'] || !ENV['PUSHER_CLUSTER']
      return false
    end

    return true
  end

  def is_store_open_time
    # get the current time in UTC
    current_time_utc = Time.now.utc

    # convert the time to EST
    current_time_est = current_time_utc.getlocal("-05:00")
    est_time_hour = current_time_est.hour

    return (est_time_hour >= 8 && est_time_hour < 23)
  end

  def broadcast_changes_destroy
    Rails.logger.info("======= BROADCAST DESTROY ======= #{self.inspect}")
    if has_pusher_env && is_store_open_time
      Pusher.trigger("store_products_#{self.store_id}", 'product_destroyed', {
        product: self.as_json
      })
    end
  end

  def broadcast_changes_update
    if self.latest_update_source == 'webhooks'
      Rails.logger.info("======= IGNORING WEBHOOKS FOR PUSHER ======= STORE_PRODUCT_ID: #{self.id}")
      
      return
    end

    relevant_fields = ['store_category_id', 'name', 'description', 'stock', 'sku', 'status', 'primary_image_id', 'thumb_image_id', 'brand_id', 'weight', 'status', 'last_updated_websocket', 'tag_list', 'is_medical_only', 'is_full_screen']
    changed_fields = self.previous_changes.keys & relevant_fields
    Rails.logger.info("======= CHANGED FIELDS ======= #{changed_fields}")
    Rails.logger.info("======= PREVIOUS CHANGES ======= #{self.previous_changes}")

    if changed_fields.length === 1 && changed_fields.include?('tag_list')
      lowercase_arrays = self.previous_changes["tag_list"].map { |array| array.map(&:downcase) }
      tag_is_equal = lowercase_arrays[0].sort == lowercase_arrays[1].sort
      if tag_is_equal
        return
      end
    end

    if self.previous_changes.keys.include?('stock')
      old_stock, new_stock = self.previous_changes['stock']
      stock_is_equal = old_stock == new_stock
    end

    if changed_fields.any? && !stock_is_equal && has_pusher_env && is_store_open_time
      begin
        product = KioskProduct.includes(
          :brand,
          :store_category,
          :primary_image,
          :thumb_image,
          :product_values,
          :images,
          :store_category_taxes,
          :store_taxes,
          :store,
          :kiosk,
          :video,
          :product_variant,
          :tags,
          :rfid_products,
          store_product: [
            :store_product_promotions,
            :images,
            :own_images,
            { brand: :logo }
          ]
        ).find_by(store_product_id: self.id)

        attribute_values = AttributeValue.where(target_id: self.id).map do |attribute_value|
          {
            name: AttributeDef.find(attribute_value.attribute_def_id).name,
            value: attribute_value.value
          }
        end

        product_values = product.product_values.map do |pv|
          { name: pv.name, value: pv.value, id: pv.id, updated_at: pv.created_at, created_at: pv.created_at }
        end

        json = {
          "product" => {
            "id" => self.id,
            "video_url" => product.video_for_catalog&.url,
            "created_at" => self.created_at,
            "updated_at" => self.updated_at,
            "isFeatured" => product.featured_product?,
            "attribute_values" => attribute_values.empty? ? {} : { "ungrouped" => attribute_values },
            "featured" => product.featured_product?,
            "status" => product.status[self.status],
            "name" => product.name,
            "description" => product.description,
            "sku" => product.sku,
            "tag_list" => product.tags.map(&:name),
            "stock" => product.stock,
            "rfids" => product.rfid_products.map(&:rfid),
            "brand" => product.brand&.as_json(only: [:id, :name, :created_at, :updated_at], methods: [:logo]),
            "catalog_category" => product.store_category&.as_json(only: [:id, :name, :created_at, :updated_at, :order]),
            "primary_image" => product.primary_image,
            "thumb_image" => product.thumb_image,
            "product_values" => product_values,
            "images" => product.images + product.own_images,  
            "video" => product.video_for_catalog&.url,
            "store_taxes" => product.store_taxes,
            "category_taxes" => product.store_category_taxes,
            "store_product_promotions" => product.store_product.store_product_promotions,
            "is_medical_only" => self.is_medical_only,
            "is_full_screen" => self.is_full_screen,
          }
        }

        Rails.logger.info "======= PUSHER UPDATE MODEL JSON ======= #{json["product"]}"

        Pusher.trigger("store_products_#{self.store_id}", 'product_updated', {
          changes: self.previous_changes,
          product: json["product"]
        })
      rescue => e
        Rails.logger.info("======= PUSHER UPDATE MODEL ERROR =======")
        Rails.logger.info(e)
        Rails.logger.info("==============")
      end
    end
  end

  # For algolia, product_id soes not change
  def will_save_change_to_product_id?
    new_record?
  end

  def store_category_taxes
    store_category.taxes
  end

  def name_for_catalog
    name || product_variant.name || product_variant.product_name
  end

  def description_for_catalog
    description || product_variant.description || product_variant.product_description
  end

  def video_for_catalog
    video || product_variant.video || product_variant.product_video
  end

  def video_url
    video&.url
  end

  def brand_for_catalog
    brand || product_variant.brand
  end

  def merged_reviews
    reviews_id = product_variant.reviews.map(&:id) + product.reviews.map(&:id)
    Review.find(reviews_id)
  end

  def attribute_value_by_name(name)
    product_variant.attribute_values.with_name(name).first ||
      product_variant.product_attribute_values.with_name(name).first
  end

  def products_tags
    # WARNING Do not use "tag_list", use preloaded relation "tags" instead
    p_tags = tags.map(&:name)

    unless override_tags
      p_tags += product_variant.tags.map(&:name)

      p_tags += product.tags.map(&:name) unless product_variant.override_tags
    end

    p_tags.uniq
  end

  # Prevent algolia reindex every save
  def will_save_change_to_store_category?
    will_save_change_to_store_category_id?
  end

  def merged_attribute_values
    self_values = attribute_values.includes(attribute_def: :attribute_group)
    variant_values = product_variant.attribute_values.includes(attribute_def: :attribute_group)
    product_values = product.attribute_values.includes(attribute_def: :attribute_group)

    (product_variant.attribute_defs + product.attribute_defs + attribute_defs).uniq.map do |a_def|
      find_value(self_values, a_def) ||
        find_value(variant_values, a_def) ||
        find_value(product_values, a_def)
    end
  end

  def update_thumb_primary_image!
    if @primary_image_url.present?
      self.primary_image = own_images.detect { |img| img.url == @primary_image_url }
    end

    if @thumb_image_url.present?
      self.thumb_image = own_images.detect { |img| img.url == @thumb_image_url }
    end

    save!
  end
  def update_existing_product(response)
      prices = (Array.wrap(response["pricing"])  || []).map do |p|
        price_name =  p["name"] || ''
        current_price = self.product_values.find_by(name: price_name)
        id = current_price ? current_price.id : nil
        {name: price_name, value: p["price_sell"], id: id}
      end
      prices_to_destroy = product_values
                            .reject { |pv| prices.any? { |p| p[:id] == pv.id } }
                            .map { |pv| {id: pv.id, _destroy: true} }
      hide_from_menu = response.dig("e_commerce", "hide_from_menu")
      deactivated_item = store.api_type_treez? && !(response["product_status"] == "ACTIVE" && !hide_from_menu)
      attrs = {
        stock: (deactivated_item ? 0 : response["sellable_quantity"]),
        status: self.status,
        latest_update_source: 'sync_job'
      }
  
      if store.override_on_sync
        attrs[:name] = response.dig("product_configurable_fields", "name").to_s.strip || name
        attrs[:description] = response.dig("e_commerce", "product_description") || description
        attrs[:store_category_id] = store_category_id
        all_images = response.dig("e_commerce", "all_images")
        # attrs[:brand_id] = brand_id
        # attrs[:weight] = weight
        #attrs[:primary_image_url] = primary_img
        #attrs[:thumb_image_url] = primary_img
        if all_images
          images_attrs = []
          primary_image = response.dig("e_commerce", "primary_image")
          if primary_image.present?
            # only add image if it doesn't exists
            unless own_images.detect { |img| img.url == primary_image }
              images_attrs << {url: primary_image}
              create_image = self.create_primary_image(url: primary_image, imageable_id: self.id, imageable_type: self.class)
              
              attrs[:primary_image_id] = create_image.try(:id)

              attrs[:thumb_image_id] =  create_image.try(:id)
              attrs[:own_image_ids]  = own_image_ids << create_image.try(:id)
            end
          end
          if images_attrs.present?
            # Destroy current images
            # images_attrs += own_image_ids.map { |id| {_destroy: true, id: id} }
            # attrs[:own_images_attributes] = images_attrs
          end
        end
      end
  
      update(attrs)
  end
  def self.update_single_response(response:, store_id:)
    @store = Store.find store_id
    product = @store.store_products.find_by(sku: response['product_id'] || response['sku'])
    if product
      Rails.logger.info "updating existing product #{product.sku}"
      product.update_existing_product(response)
    else
      #create_product(response)
    end
  end


  private

  def sanitize_override_tags
    self.override_tags = false unless override_tags
  end

  def nilify_blank_attributes
    self.name = nil if name.blank?
  end

  def check_image_owner(image)
    allowed_ids = product_variant.image_ids

    raise 'Only images from parent product are allowed' unless allowed_ids.include?(image.id)
  end

  def assign_images_by_url
    if @primary_image_url.present?
      self.primary_image = own_images.detect { |img| img.url == @primary_image_url }
    end

    if @thumb_image_url.present?
      self.thumb_image = own_images.detect { |img| img.url == @thumb_image_url }
    end

    nil
  end

  def check_main_images_ownership
    allowed_ids = image_ids + own_image_ids

    raise 'Primary image should belongs to this product' if primary_image_id &&
                                                            !allowed_ids.include?(primary_image_id)

    raise 'Thumb image should belongs to this product' if thumb_image_id &&
                                                          !allowed_ids.include?(thumb_image_id)
  end

  def assign_default_main_image
    self.primary_image_id = image_ids.first if !primary_image_id && !primary_image

    self.thumb_image_id = image_ids.first if !thumb_image_id && !thumb_image
  end

  def denormalize_store_id
    return unless store_category

    self.store_id = store_category.store_id
  end

  def assign_default_image
    return if !product_variant || product_variant.images.empty? || images.present?

    images << product_variant.images.first
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

    # Replace primary and thumb images if removed
    self.primary_image_id = image_ids.first if primary_image == image
    self.thumb_image_id = image_ids.first if thumb_image == image
  end

  def create_kiosks_products
    store.kiosks.product_filter_criteria_all.find_each do |kiosk|
      kiosk.kiosk_products.create!(store_product: self)
    end

    store.kiosks
         .product_filter_criteria_category
         .where(product_filter_value: store_category)
         .find_each do |kiosk|
           kiosk.kiosk_products.create!(store_product: self)
         end

    if brand_for_catalog.present?
      store.kiosks
           .product_filter_criteria_brand
           .where(product_filter_value: brand_for_catalog)
           .find_each do |kiosk|
        kiosk.kiosk_products.create!(store_product: self)
      end
    end

    nil
  end

  def update_kiosks_products
    if saved_change_to_store_category_id?
      update_kiosks_products_by_criteria(
        criteria: :category, type: 'StoreCategory', property: :store_category
      )
    end

    if saved_change_to_brand_id?
      update_kiosks_products_by_criteria(
        criteria: :brand, type: 'Brand', property: :brand_for_catalog
      )
    end

    nil
  end

  def update_kiosks_products_by_criteria(criteria:, type:, property:)
    # Remove from kiosk with previous brand
    kiosk_was_scope = Kiosk.where(
      product_filter_criteria: criteria,
      product_filter_value_type: type,
      product_filter_value_id: send("#{property}_id_before_last_save")
    )
    kiosk_products.joins(:kiosk).merge(kiosk_was_scope).find_each(&:destroy)

    # Add to new kiosks
    store.kiosks
         .where(product_filter_criteria: criteria, product_filter_value: send(property))
         .find_each do |kiosk|
           kiosk.kiosk_products.create!(store_product: self)
         end
  end

  def brand_for_catalog_id_before_last_save
    brand_id_before_last_save || product_variant.brand&.id
  end

  def log_to_catch_rfid
    Rails.logger.info("======= RFID ISSUE TO CATCH FROM STORE PRODUCT MODEL =======")
    Rails.logger.info("PRODUCT: #{self.inspect}")
    Rails.logger.info("==============")
  end


def self.create_product(response)
end



end

# == Schema Information
#
# Table name: store_products
#
#  id                     :bigint           not null, primary key
#  description            :string
#  has_promotion          :boolean          default(FALSE)
#  inventory_type_medical :boolean          default(FALSE)
#  is_full_screen         :boolean          default(FALSE)
#  is_medical_only        :boolean          default(FALSE)
#  last_updated_websocket :datetime
#  latest_update_source   :string
#  latest_update_token    :string
#  name                   :string
#  override_tags          :boolean          default(FALSE)
#  share_email_template   :string
#  share_sms_template     :string
#  sku                    :string
#  status                 :integer          default("published")
#  stock                  :integer          default(0), not null
#  weight                 :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  brand_id               :bigint
#  primary_image_id       :bigint
#  product_variant_id     :bigint
#  store_category_id      :bigint
#  store_id               :bigint
#  thumb_image_id         :bigint
#
# Indexes
#
#  index_store_products_on_brand_id            (brand_id)
#  index_store_products_on_product_variant_id  (product_variant_id)
#  index_store_products_on_store_category_id   (store_category_id)
#  index_store_products_on_store_id            (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id)
#  fk_rails_...  (primary_image_id => images.id)
#  fk_rails_...  (product_variant_id => product_variants.id)
#  fk_rails_...  (store_category_id => store_categories.id)
#  fk_rails_...  (store_id => stores.id)
#  fk_rails_...  (thumb_image_id => images.id)
#
