# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_12_02_230146) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "ad_banner_locations", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "codename"
    t.string "special_type"
    t.index ["text"], name: "index_ad_banner_locations_on_text", unique: true
  end

  create_table "ad_banners", force: :cascade do |t|
    t.string "text"
    t.bigint "store_id", null: false
    t.bigint "ad_banner_location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "callback_url"
    t.string "advertisable_type"
    t.bigint "advertisable_id"
    t.boolean "disabled", default: false
    t.index ["ad_banner_location_id"], name: "index_ad_banners_on_ad_banner_location_id"
    t.index ["advertisable_type", "advertisable_id"], name: "index_ad_banners_on_advertisable_type_and_advertisable_id"
    t.index ["store_id"], name: "index_ad_banners_on_store_id"
  end

  create_table "ad_configs", force: :cascade do |t|
    t.string "name"
    t.bigint "kiosk_id"
    t.bigint "kiosk_product_id"
    t.bigint "brand_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "use_brand_spotlight", default: false
    t.index ["brand_id"], name: "index_ad_configs_on_brand_id"
    t.index ["kiosk_id"], name: "index_ad_configs_on_kiosk_id"
    t.index ["kiosk_product_id"], name: "index_ad_configs_on_kiosk_product_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.string "excerpt"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_articles_on_category_id"
  end

  create_table "asset_elements", force: :cascade do |t|
    t.string "coord_x"
    t.string "coord_y"
    t.string "link"
    t.string "kiosk_asset_id"
    t.integer "element_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assets", force: :cascade do |t|
    t.string "url"
    t.integer "source_id"
    t.string "source_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribute_defs", force: :cascade do |t|
    t.string "name"
    t.bigint "attribute_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "restricted", default: false
    t.string "values"
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_attribute_defs_on_name"
    t.index ["attribute_group_id"], name: "index_attribute_defs_on_attribute_group_id"
  end

  create_table "attribute_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_type", default: 0
    t.integer "order"
  end

  create_table "attribute_values", force: :cascade do |t|
    t.string "value"
    t.bigint "attribute_def_id"
    t.integer "target_id"
    t.string "target_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_def_id"], name: "index_attribute_values_on_attribute_def_id"
    t.index ["target_id", "target_type", "attribute_def_id"], name: "index_attribute_values_on_target_and_def"
    t.index ["target_id", "target_type"], name: "index_attribute_values_on_target_id_and_target_type"
    t.index ["target_id"], name: "index_attribute_values_on_target_id"
    t.index ["target_type"], name: "index_attribute_values_on_target_type"
  end

  create_table "audit_rfid_products", id: :serial, force: :cascade do |t|
    t.string "rfid", null: false
    t.string "rfid_entity_id"
    t.datetime "date", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "type", null: false
    t.integer "kiosk_id"
    t.integer "rfid_numbers"
    t.string "type_update"
  end

  create_table "brand_and_store_categories", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "store_category_id", null: false
    t.bigint "kiosk_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id", "store_category_id"], name: "index_brand_and_store", unique: true
    t.index ["brand_id"], name: "index_brand_and_store_categories_on_brand_id"
    t.index ["kiosk_id"], name: "index_brand_and_store_categories_on_kiosk_id"
    t.index ["store_category_id"], name: "index_brand_and_store_categories_on_store_category_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index "replace(lower((name)::text), ' '::text, ''::text)", name: "index_brand_on_name_case_space_insensitive"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "store_product_id", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["store_product_id"], name: "index_cart_items_on_store_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.boolean "is_active"
    t.string "phone_number"
    t.datetime "checkout_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["updated_at"], name: "index_carts_on_updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_orders", force: :cascade do |t|
    t.integer "customer_id"
    t.string "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.decimal "amount"
    t.string "status"
    t.text "data"
    t.datetime "printed_date"
    t.string "printed_id"
    t.index ["customer_id"], name: "index_customer_orders_on_customer_id"
    t.index ["store_id"], name: "index_customer_orders_on_store_id"
  end

  create_table "customer_syncs", force: :cascade do |t|
    t.integer "status", default: 0
    t.bigint "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_account_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "status"
    t.string "customer_id"
    t.string "first_name"
    t.string "last_name"
    t.string "gender"
    t.string "birthday"
    t.string "email"
    t.string "phone"
    t.string "drivers_license"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id"
    t.string "external_account_id"
    t.string "last_modified_date_utc"
    t.index "lower((email)::text)", name: "index_customers_on_lowercase_email"
    t.index "replace(replace(replace(replace((phone)::text, '-'::text, ''::text), ' '::text, ''::text), '('::text, ''::text), ')'::text, ''::text)", name: "idx_customer_phone"
    t.index "store_id, lower((status)::text)", name: "index_customers_on_store_id_and_status"
  end

  create_table "duplicated_sku_deleted_logs", force: :cascade do |t|
    t.string "deleted_sku"
    t.string "deleted_store_product_id"
    t.bigint "store_id"
    t.bigint "store_product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["store_id"], name: "index_duplicated_sku_deleted_logs_on_store_id"
    t.index ["store_product_id"], name: "index_duplicated_sku_deleted_logs_on_store_product_id"
  end

  create_table "expired_kiosk_products", force: :cascade do |t|
    t.bigint "kiosk_id", null: false
    t.bigint "store_id", null: false
    t.string "store_product_id"
    t.datetime "expired_at"
    t.datetime "last_updated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["kiosk_id"], name: "index_expired_kiosk_products_on_kiosk_id"
    t.index ["store_id"], name: "index_expired_kiosk_products_on_store_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.string "user_id", null: false
    t.bigint "store_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["store_id"], name: "index_favorites_on_store_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "url", null: false
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "images_product_variants", id: false, force: :cascade do |t|
    t.bigint "product_variant_id", null: false
    t.bigint "image_id", null: false
    t.index ["image_id", "product_variant_id"], name: "images_variant_join_table"
    t.index ["product_variant_id", "image_id"], name: "variant_images_join_table"
  end

  create_table "images_store_products", id: false, force: :cascade do |t|
    t.bigint "store_product_id", null: false
    t.bigint "image_id", null: false
    t.index ["image_id", "store_product_id"], name: "image_catalog_product_join_table"
    t.index ["store_product_id", "image_id"], name: "catalog_product_image_join_table"
  end

  create_table "kiosk_assets", force: :cascade do |t|
    t.string "text"
    t.text "secondary_text"
    t.integer "text_position_id"
    t.integer "asset_position_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kiosk_layout_id"
    t.string "code"
    t.integer "section_position_id", default: 10
    t.index ["kiosk_layout_id"], name: "index_kiosk_assets_on_kiosk_layout_id"
  end

  create_table "kiosk_layouts", force: :cascade do |t|
    t.integer "template", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "welcome_asset_id"
    t.integer "home_layout"
    t.boolean "rfid_disabled", default: false
    t.boolean "shopping_disabled", default: false
    t.text "welcome_message"
    t.bigint "kiosk_id"
    t.integer "stand_side", default: 0
    t.bigint "product_layout_id"
    t.integer "screen_type", default: 1
    t.bigint "store_category_id"
    t.boolean "on_sale_badges"
    t.string "checkout_text"
    t.integer "pagination_time"
    t.string "home_screen_title"
    t.integer "nav_ui", default: 0
    t.boolean "fast_animation", default: false
    t.boolean "disable_overlay_mask", default: false
    t.bigint "video_image_background_asset_id"
    t.index ["kiosk_id"], name: "index_kiosk_layouts_on_kiosk_id"
    t.index ["product_layout_id"], name: "index_kiosk_layouts_on_product_layout_id"
    t.index ["store_category_id"], name: "index_kiosk_layouts_on_store_category_id"
    t.index ["video_image_background_asset_id"], name: "index_kiosk_layouts_on_video_image_background_asset_id"
    t.index ["welcome_asset_id"], name: "index_kiosk_layouts_on_welcome_asset_id"
  end

  create_table "kiosk_products", force: :cascade do |t|
    t.bigint "store_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kiosk_id"
    t.boolean "featured", default: false
    t.text "stylesheet"
    t.index ["kiosk_id"], name: "index_kiosk_products_on_kiosk_id"
    t.index ["store_product_id"], name: "index_kiosk_products_on_store_product_id"
  end

  create_table "kiosks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id"
    t.boolean "active", default: true
    t.text "data"
    t.integer "product_filter_criteria", default: 0
    t.string "product_filter_value_type"
    t.bigint "product_filter_value_id"
    t.string "rfid_sorting", default: "0"
    t.string "rfid_behavior", default: "0"
    t.string "location"
    t.index ["product_filter_criteria", "product_filter_value_type", "product_filter_value_id"], name: "index_kiosks_product_filter_criteria"
    t.index ["product_filter_value_type", "product_filter_value_id"], name: "index_kiosks_on_product_filter_value"
    t.index ["store_id"], name: "index_kiosks_on_store_id"
  end

  create_table "layout_navigation_items", force: :cascade do |t|
    t.string "label"
    t.string "link"
    t.integer "order", default: 0
    t.bigint "layout_navigation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description"
    t.index ["layout_navigation_id"], name: "index_layout_navigation_items_on_layout_navigation_id"
  end

  create_table "layout_navigations", force: :cascade do |t|
    t.bigint "kiosk_layout_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kiosk_layout_id"], name: "index_layout_navigations_on_kiosk_layout_id"
  end

  create_table "layout_positions", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_gateway_providers", force: :cascade do |t|
    t.string "name"
    t.string "fields", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_gateways", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "payment_gateway_provider_id", null: false
    t.json "api_settings"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "projects", default: [], array: true
    t.index ["payment_gateway_provider_id"], name: "index_payment_gateways_on_payment_gateway_provider_id"
    t.index ["store_id"], name: "index_payment_gateways_on_store_id"
  end

  create_table "product_layout_elements", force: :cascade do |t|
    t.integer "element_type"
    t.string "coord_x"
    t.string "coord_y"
    t.string "hint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "width"
    t.string "source_type"
    t.bigint "source_id"
    t.index ["source_type", "source_id"], name: "index_product_layout_elements_on_source_type_and_source_id"
  end

  create_table "product_layout_tabs", force: :cascade do |t|
    t.bigint "product_layout_id"
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_layout_id"], name: "index_product_layout_tabs_on_product_layout_id"
  end

  create_table "product_layout_values", force: :cascade do |t|
    t.bigint "product_layout_element_id"
    t.bigint "kiosk_product_id"
    t.string "link"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kiosk_product_id"], name: "index_product_layout_values_on_kiosk_product_id"
    t.index ["product_layout_element_id"], name: "index_product_layout_values_on_product_layout_element_id"
  end

  create_table "product_layouts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "stylesheet"
    t.index "lower((name)::text)", name: "index_product_layouts_on_name", unique: true
  end

  create_table "product_values", force: :cascade do |t|
    t.string "name"
    t.decimal "value", precision: 10, scale: 2
    t.string "valuable_type"
    t.bigint "valuable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["valuable_type", "valuable_id"], name: "index_product_values_on_valuable_type_and_valuable_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "brand_id"
    t.string "description"
    t.string "sku"
    t.boolean "override_tags", default: false
    t.index ["brand_id"], name: "index_product_variants_on_brand_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.string "description"
    t.boolean "is_full_screen", default: false
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_products_on_name"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "purchase_limits", force: :cascade do |t|
    t.bigint "store_setting_id"
    t.integer "limit", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["store_setting_id"], name: "index_purchase_limits_on_store_setting_id"
  end

  create_table "purchase_limits_store_categories", id: false, force: :cascade do |t|
    t.bigint "purchase_limit_id", null: false
    t.bigint "store_category_id", null: false
    t.index ["purchase_limit_id", "store_category_id"], name: "puchase_limit_store_categories_join_table"
    t.index ["store_category_id", "purchase_limit_id"], name: "store_categories_puchase_limit_join_table"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "user"
    t.string "rate"
    t.string "text"
    t.string "reviewable_type"
    t.bigint "reviewable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
  end

  create_table "rfid_products", force: :cascade do |t|
    t.string "rfid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kiosk_id"
    t.string "rfid_entity_type"
    t.bigint "rfid_entity_id"
    t.integer "order", default: 0
    t.index ["kiosk_id"], name: "index_rfid_products_on_kiosk_id"
    t.index ["rfid_entity_type", "rfid_entity_id"], name: "index_rfid_products_on_rfid_entity_type_and_rfid_entity_id"
  end

  create_table "store_articles", force: :cascade do |t|
    t.bigint "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.index ["article_id"], name: "index_store_articles_on_article_id"
    t.index ["store_id"], name: "index_store_articles_on_store_id"
  end

  create_table "store_articles_products", id: false, force: :cascade do |t|
    t.bigint "store_article_id", null: false
    t.bigint "store_product_id", null: false
    t.index ["store_article_id", "store_product_id"], name: "catalog_article_product_join_table"
    t.index ["store_product_id", "store_article_id"], name: "product_catalog_article_join_table"
  end

  create_table "store_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.bigint "store_id"
    t.text "tax"
    t.index ["store_id"], name: "index_store_categories_on_store_id"
  end

  create_table "store_category_kiosk_layouts", force: :cascade do |t|
    t.bigint "store_category_id", null: false
    t.bigint "kiosk_layout_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order"
    t.index ["kiosk_layout_id"], name: "index_store_category_kiosk_layouts_on_kiosk_layout_id"
    t.index ["store_category_id"], name: "index_store_category_kiosk_layouts_on_store_category_id"
  end

  create_table "store_category_taxes", force: :cascade do |t|
    t.string "name"
    t.float "value"
    t.bigint "store_category_id"
    t.index ["store_category_id"], name: "index_store_category_taxes_on_store_category_id"
  end

  create_table "store_prices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.index ["store_id"], name: "index_store_prices_on_store_id"
  end

  create_table "store_product_promotions", force: :cascade do |t|
    t.text "promotion"
    t.bigint "store_product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "promotion_id"
    t.string "promotion_name"
    t.decimal "discount_price", precision: 10, scale: 2, default: "0.0"
    t.string "discount_type"
    t.index ["store_product_id"], name: "index_store_product_promotions_on_store_product_id"
  end

  create_table "store_products", force: :cascade do |t|
    t.bigint "store_category_id"
    t.bigint "product_variant_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "stock", default: 0, null: false
    t.bigint "primary_image_id"
    t.bigint "thumb_image_id"
    t.string "sku"
    t.boolean "override_tags", default: false
    t.bigint "brand_id"
    t.string "share_email_template"
    t.integer "status", default: 1
    t.bigint "store_id"
    t.string "share_sms_template"
    t.decimal "weight"
    t.string "latest_update_source"
    t.boolean "inventory_type_medical", default: false
    t.string "latest_update_token"
    t.boolean "has_promotion", default: false
    t.datetime "last_updated_websocket"
    t.boolean "is_medical_only", default: false
    t.boolean "is_full_screen", default: false
    t.index ["brand_id"], name: "index_store_products_on_brand_id"
    t.index ["product_variant_id"], name: "index_store_products_on_product_variant_id"
    t.index ["store_category_id"], name: "index_store_products_on_store_category_id"
    t.index ["store_id"], name: "index_store_products_on_store_id"
  end

  create_table "store_settings", force: :cascade do |t|
    t.integer "store_id"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_store_settings_on_store_id"
  end

  create_table "store_sync_items", force: :cascade do |t|
    t.bigint "store_sync_id"
    t.text "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.boolean "inventory_type_medical", default: false
    t.index ["created_at"], name: "store_sync_items_created_at_index", order: :desc
    t.index ["store_sync_id"], name: "index_store_sync_items_on_store_sync_id"
  end

  create_table "store_syncs", force: :cascade do |t|
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.index ["store_id"], name: "index_store_syncs_on_store_id"
  end

  create_table "store_taxes", force: :cascade do |t|
    t.string "name"
    t.float "value"
    t.bigint "store_id"
    t.index ["store_id"], name: "index_store_taxes_on_store_id"
  end

  create_table "stores", force: :cascade do |t|
    t.bigint "client_id"
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.text "api_settings"
    t.text "notification_settings"
    t.integer "featured_mode", default: 0
    t.boolean "enabled_share_email_product", default: false
    t.boolean "enabled_share_sms_product", default: false
    t.text "tax"
    t.boolean "block_simultaneous_nfc", default: false
    t.json "webhook_url"
    t.string "last_sync_update"
    t.string "next_initial_sync"
    t.string "access_token"
    t.boolean "enable_continuous_cart", default: false
    t.boolean "enabled_continuous_cart", default: false
    t.index ["client_id"], name: "index_stores_on_client_id"
  end

  create_table "tag_infos", force: :cascade do |t|
    t.string "tag"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag"], name: "index_tag_infos_on_tag", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.integer "client_id"
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "video_image_background_assets", force: :cascade do |t|
    t.integer "asset_position_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "welcome_assets", force: :cascade do |t|
    t.integer "asset_position_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ad_banners", "ad_banner_locations"
  add_foreign_key "ad_banners", "stores"
  add_foreign_key "ad_configs", "brands"
  add_foreign_key "ad_configs", "kiosk_products"
  add_foreign_key "ad_configs", "kiosks"
  add_foreign_key "articles", "categories"
  add_foreign_key "attribute_defs", "attribute_groups"
  add_foreign_key "attribute_values", "attribute_defs"
  add_foreign_key "brand_and_store_categories", "brands"
  add_foreign_key "brand_and_store_categories", "kiosks"
  add_foreign_key "brand_and_store_categories", "store_categories"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "store_products"
  add_foreign_key "customer_orders", "stores"
  add_foreign_key "duplicated_sku_deleted_logs", "store_products"
  add_foreign_key "duplicated_sku_deleted_logs", "stores"
  add_foreign_key "expired_kiosk_products", "kiosks"
  add_foreign_key "expired_kiosk_products", "stores"
  add_foreign_key "kiosk_assets", "kiosk_layouts"
  add_foreign_key "kiosk_layouts", "kiosks"
  add_foreign_key "kiosk_layouts", "product_layouts"
  add_foreign_key "kiosk_layouts", "store_categories"
  add_foreign_key "kiosk_layouts", "video_image_background_assets"
  add_foreign_key "kiosk_layouts", "welcome_assets"
  add_foreign_key "kiosk_products", "kiosks"
  add_foreign_key "kiosk_products", "store_products"
  add_foreign_key "kiosks", "stores"
  add_foreign_key "layout_navigation_items", "layout_navigations"
  add_foreign_key "layout_navigations", "kiosk_layouts"
  add_foreign_key "payment_gateways", "payment_gateway_providers"
  add_foreign_key "payment_gateways", "stores"
  add_foreign_key "product_layout_tabs", "product_layouts"
  add_foreign_key "product_layout_values", "kiosk_products"
  add_foreign_key "product_layout_values", "product_layout_elements"
  add_foreign_key "product_variants", "brands"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "purchase_limits", "store_settings"
  add_foreign_key "rfid_products", "kiosks"
  add_foreign_key "store_articles", "articles"
  add_foreign_key "store_articles", "stores"
  add_foreign_key "store_articles_products", "store_articles"
  add_foreign_key "store_articles_products", "store_products"
  add_foreign_key "store_categories", "stores"
  add_foreign_key "store_category_kiosk_layouts", "kiosk_layouts"
  add_foreign_key "store_category_kiosk_layouts", "store_categories"
  add_foreign_key "store_prices", "stores"
  add_foreign_key "store_product_promotions", "store_products"
  add_foreign_key "store_products", "brands"
  add_foreign_key "store_products", "images", column: "primary_image_id"
  add_foreign_key "store_products", "images", column: "thumb_image_id"
  add_foreign_key "store_products", "product_variants"
  add_foreign_key "store_products", "store_categories"
  add_foreign_key "store_products", "stores"
  add_foreign_key "store_settings", "stores"
  add_foreign_key "store_sync_items", "store_syncs"
  add_foreign_key "store_syncs", "stores"
  add_foreign_key "stores", "clients"
end
