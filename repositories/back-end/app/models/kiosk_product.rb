class KioskProduct < ApplicationRecord
  include AlgoliaSearch

  # before_validation :denormalize_store_id

  algoliasearch per_environment: true,
                auto_index: false, auto_remove: false,
                disable_indexing: proc {
                  Rails.env.test? || ENV['ALGOLIASEARCH_DISABLED'] == 'true'
                } do
    attribute :kiosk_id

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
      'equalOnly(kiosk_id)',
      'equalOnly(store_category.id)',
      'equalOnly(product_id)',
      'equalOnly(brand_id)'
    ]

    searchableAttributes ['name', 'store_category.name', 'unordered(description)']
  end

  belongs_to :kiosk
  belongs_to :store_product
  has_one :store, through: :store_category

  has_many :product_values, through: :store_product
  has_many :images, through: :store_product
  has_many :own_images, through: :store_product
  has_many :attribute_values, through: :store_product
  has_many :rfid_products, dependent: :destroy, as: :rfid_entity
  has_many :tags, through: :store_product
  has_many :product_layout_values, dependent: :destroy
  accepts_nested_attributes_for :product_layout_values, allow_destroy: true, reject_if: :all_blank

  has_one :store, through: :kiosk
  has_one :brand, through: :store_product
  has_one :product_variant, through: :store_product
  has_one :thumb_image, through: :store_product
  has_one :primary_image, through: :store_product
  has_one :store_category, through: :store_product
  has_many :store_category_taxes, through: :store_category
  has_many :store_taxes, through: :store
  has_one :video, through: :store_product

  delegate :sku, :name, :tag_list, :description, :share_email_template,
           :stock, :override_tags, :status, :brand_for_catalog,
           :name_for_catalog, :description_for_catalog, :video_for_catalog,
           :products_tags, :product, :merged_reviews,
           to: :store_product

  scope :name_like, lambda { |name|
    joins(:store_product).merge(StoreProduct.name_like(name))
  }

  after_update_commit :notify_store_product_update
  after_create_commit :notify_store_product_create
  after_destroy_commit :notify_store_product_destroy

  def is_full_screen
    store_product&.is_full_screen
  end
  
  def notify_store_product_create
    store_product = StoreProduct.find(self.store_product_id)
    store_product.update(last_updated_websocket: Time.current)
  end

  def notify_store_product_update
    relevant_fields = ['featured']
    changed_fields = self.previous_changes.keys & relevant_fields
    if changed_fields.any?
      store_product = StoreProduct.find(self.store_product_id)
      store_product.update(last_updated_websocket: Time.current)
    end
  end

  def notify_store_product_destroy
    if self.store_product_id
      store_product = StoreProduct.find_by(id: self.store_product_id)
      if store_product
        store_product.update(last_updated_websocket: Time.current)
      end
    end
  end

  # def denormalize_store_id
  #   return unless store_category
  #
  #   self.store_id = store_category.store_id
  # end

  def self.minimal
    joins(store_product: { product_variant: :product }).select(minimal_fields)
  end

  def featured_product?
    if store.rfid_featured?
      rfid_products.any?
    elsif store.manual_featured?
      featured
    elsif store.rfid_and_manual_featured?
      rfid_products.any? || featured
    else
      false
    end
  end

  def rfids
    rfid_products.sort_by(&:id).map(&:rfid)
  end

  def store
    store_category.store
  end

  def self.minimal_fields
    [
      KioskProduct.arel_table[:created_at],
      updated_at_field.as('updated_at'),
      KioskProduct.arel_table[:store_product_id],
      StoreProduct.arel_table[:sku].as('store_sku'),
      StoreProduct.arel_table[:stock].as('store_stock')
    ]
  end

  def self.updated_at_field
    Arel::Nodes::NamedFunction.new('GREATEST', [
                                     KioskProduct.arel_table[:updated_at],
                                     StoreProduct.arel_table[:updated_at],
                                     ProductVariant.arel_table[:updated_at],
                                     Product.arel_table[:updated_at]
                                   ])
  end

  def self.find_by_id(id, catalog_id = nil)
    @connection = ActiveRecord::Base.connection
    results = @connection.exec_query("
        SELECT sp.id,
                 sp.created_at,
                 sp.updated_at,
                 sp.name,
                 sp.description,
                 sp.sku,
                 sp.stock,
                 sp.store_id,
                 sp.store_category_id,
                 sp.override_tags,
                 sp.product_variant_id,
                 sp.primary_image_id,
                 sp.thumb_image_id,
                 b.id         as brand_id,
                 b.name       as brand_name,
                 b.created_at as brand_created_at,
                 b.updated_at as brand_updated_at,
                 ba.url       as brand_logo,
                 bavideo.url as video_url,
                 sc.id as sc_id,
                 sc.name as sc_name,
                  sc.created_at as sc_created_at,
                sc.updated_at as sc_updated_at,
                kp.featured,
                kp.id as kiosk_products_id
        FROM store_products sp
                LEFT JOIN kiosk_products kp ON kp.store_product_id = sp.id
                 LEFT JOIN store_categories sc ON sc.id = sp.store_category_id
                 LEFT JOIN brands b ON b.id = sp.brand_id
                 LEFT JOIN assets ba ON ba.source_id = b.id AND ba.source_type = 'Brand'
                 LEFT JOIN assets bavideo ON bavideo.source_id = sp.id AND bavideo.source_type = 'StoreProduct'
        WHERE sp.id = #{id}"
    )
    store_taxes = @connection.exec_query("SELECT * FROM store_taxes st WHERE st.store_id = #{results.first['store_id']}")
    category_taxes = @connection.exec_query("SELECT * FROM store_category_taxes sct WHERE sct.store_category_id = #{results.first['store_category_id']}")
    product_values = @connection.exec_query("SELECT id, name, value, created_at, updated_at FROM product_values pv WHERE pv.valuable_id = #{results.first['id']} AND pv.valuable_type = 'StoreProduct'")
    attribute_values = @connection.exec_query("SELECT ad.name, av.value FROM attribute_values av INNER JOIN attribute_defs ad ON ad.id = av.attribute_def_id WHERE target_type = 'StoreProduct' AND target_id = #{results.first['id']}")
    images = @connection.exec_query("SELECT ig.id, ig.url, ig.created_at, ig.updated_at FROM images ig WHERE imageable_type = 'StoreProduct' AND imageable_id = #{results.first['id']}")
    primary_image = @connection.exec_query("SELECT ig.id, ig.url, ig.created_at, ig.updated_at FROM images ig WHERE id = #{results.first['primary_image_id']}")
    thumb_image = @connection.exec_query("SELECT ig.id, ig.url, ig.created_at, ig.updated_at FROM images ig WHERE id = #{results.first['thumb_image_id']}")
    video = @connection.exec_query("SELECT bavideo.id, bavideo.url, bavideo.created_at, bavideo.updated_at FROM assets bavideo WHERE source_type = 'StoreProduct' AND source_id = #{results.first['id']}")
    rfids = @connection.exec_query("SELECT rf.rfid FROM rfid_products rf WHERE rf.kiosk_product_id = #{results.first['kiosk_products_id']}")

    if(results.first['override_tags'])
      tag_list = @connection.exec_query("SELECT ts.name FROM taggings tgs INNER JOIN tags ts ON ts.id = tgs.tag_id WHERE taggable_type = 'StoreProduct' AND taggable_id = #{results.first['id']}")
    else
      product_variant = @connection.exec_query("SELECT product_id, override_tags FROM product_variants WHERE id = #{results.first['product_variant_id']}")

      if(product_variant.first['override_tags'])
        tag_list = @connection.exec_query("SELECT ts.name FROM taggings tgs INNER JOIN tags ts ON ts.id = tgs.tag_id WHERE taggable_type = 'ProductVariant' AND taggable_id = #{results.first['product_variant_id']}")
      else
        tag_list = @connection.exec_query("SELECT ts.name FROM taggings tgs INNER JOIN tags ts ON ts.id = tgs.tag_id WHERE taggable_type = 'ProductVariant' AND taggable_id = #{product_variant.first['product_id']}")
      end

      tag_list = @connection.exec_query("SELECT ts.name FROM taggings tgs INNER JOIN tags ts ON ts.id = tgs.tag_id WHERE taggable_type = 'ProductVariant' AND taggable_id = #{results.first['product_variant_id']}")
    end


    tag_list_array ||= []

    tag_list.each { |tag|
      tag_list_array.push(tag["name"])
    }

    rfids_array ||= []

    rfids.each { |rfid|
      rfids_array.push(rfid["rfid"])
    }


    brand = nil;
    if(results.first['brand_id'] != nil)
      brand = {
          "id" => results.first['brand_id'],
          "name" => results.first['brand_name'],
          "created_at" => results.first['brand_created_at'],
          "updated_at" => results.first['brand_updated_at'],
          "logo" => results.first['brand_logo']
      }
    end


      json = {
        "product" =>
        {
            "id" => results.first['id'],
            "video_url" => results.first['video_url'],
            "created_at" => results.first['created_at'],
            "updated_at" => results.first['updated_at'],
            "attribute_values" => {"ungrouped" => attribute_values},
            # "layout" => layout,
            "featured" => results.first['featured'],
            "name" => results.first['name'],
            "description" => results.first['description'],
            "sku" => results.first['sku'],
            "tag_list" => tag_list_array,
            "stock" => results.first['stock'],
            "rfids" => rfids_array,
            "brand" => brand,
            "catalog_category" => {
                "id" => results.first['sc_id'],
                "name" => results.first['sc_name'],
                "created_at" => results.first['sc_created_at'],
                "updated_at" => results.first['sc_updated_at'],
            },
            "primary_image" => primary_image,
            "thumb_image" => thumb_image,
            "product_values" => product_values,
            "images" => images,
            "video" => video,
            "taxes" => {
                "store_taxes" => store_taxes,
                "category_taxes" => category_taxes
            }
        }
    }
    # json["product"].push(
    #     {
    #
    #     })
    #
    @connection.disconnect!
    return json
  end
end

# == Schema Information
#
# Table name: kiosk_products
#
#  id               :bigint           not null, primary key
#  featured         :boolean          default(FALSE)
#  stylesheet       :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  kiosk_id         :bigint
#  store_product_id :bigint
#
# Indexes
#
#  index_kiosk_products_on_kiosk_id          (kiosk_id)
#  index_kiosk_products_on_store_product_id  (store_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_id => kiosks.id)
#  fk_rails_...  (store_product_id => store_products.id)
#
