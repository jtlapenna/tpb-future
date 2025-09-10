class InitialImgration < ActiveRecord::Migration[5.1]
  def up
    create_table "brands", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "catalog_categories", force: :cascade do |t|
      t.string "name"
      t.bigint "catalog_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["catalog_id"], name: "index_catalog_categories_on_catalog_id"
    end

    create_table "catalog_products", force: :cascade do |t|
      t.bigint "catalog_category_id"
      t.bigint "product_variant_id"
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["catalog_category_id"], name: "index_catalog_products_on_catalog_category_id"
      t.index ["product_variant_id"], name: "index_catalog_products_on_product_variant_id"
    end

    create_table "catalogs", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "store_id"
      t.index ["store_id"], name: "index_catalogs_on_store_id"
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

    create_table "product_variants", force: :cascade do |t|
      t.bigint "product_id"
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "brand_id"
      t.index ["brand_id"], name: "index_product_variants_on_brand_id"
      t.index ["product_id"], name: "index_product_variants_on_product_id"
    end

    create_table "products", force: :cascade do |t|
      t.string "name"
      t.string "code"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "category_id"
      t.index ["category_id"], name: "index_products_on_category_id"
    end

    create_table "stores", force: :cascade do |t|
      t.bigint "client_id"
      t.string "name"
      t.boolean "active", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["client_id"], name: "index_stores_on_client_id"
    end

    add_foreign_key "catalog_categories", "catalogs"
    add_foreign_key "catalog_products", "catalog_categories"
    add_foreign_key "catalog_products", "product_variants"
    add_foreign_key "catalogs", "stores"
    add_foreign_key "product_variants", "brands"
    add_foreign_key "product_variants", "products"
    add_foreign_key "products", "categories"
    add_foreign_key "stores", "clients"
  end
end
