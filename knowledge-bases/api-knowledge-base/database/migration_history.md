# Database Migration History

## Overview
This document tracks the evolution of the database schema through migrations, organized chronologically and by functionality.

## 2024 Migrations

### Cart System Updates
- `20241019161124_remove_product_id_from_cart_items.rb`: Removed direct product ID reference
- `20241019155933_add_store_product_id_to_cart_items.rb`: Added store product association

### Product Management
- `20240802200630_add_last_updated_websocket_to_store_products.rb`: Added websocket update tracking
- `20240305171155_add_promotion_columns_to_store_product_promotions.rb`: Enhanced promotion functionality

## 2023 Migrations

### Customer Management
- `20230616201542_add_column_to_customers.rb`: Added new customer attributes

## 2022 Migrations

### Product Management
- `20220318112549_add_latest_update_source_to_store_products.rb`: Added update source tracking
- `20220217174245_drop_table_store_product_variants.rb`: Simplified product variant structure

## 2021 Migrations

### Feature Additions
- `20210831021211_create_favorites.rb`: Added customer favorites functionality
- `20210622231251_create_ad_configs.rb`: Implemented advertisement configuration

## 2020 Migrations

### Store Management
- `20200521195251_change_tax_into_store.rb`: Modified tax handling
- `20200520154023_add_tax_to_stores.rb`: Added tax configuration

### Customer Management
- `20200428141634_update_rfid_product_data.rb`: Updated RFID product data
- `20200222010024_add_index_to_customer_phone.rb`: Optimized customer phone lookup

## 2019 Migrations

### Store and Product Management
- `20191127164310_add_weight_to_store_products.rb`: Added product weight tracking
- `20191113190555_add_index_customer_id_and_active_to_customers.rb`: Optimized customer queries
- `20191113172408_rename_column_birthdaydate_to_birthday_to_customers.rb`: Standardized date field naming

### Store Configuration
- `20190808210451_add_stylesheet_to_product_layout.rb`: Enhanced layout customization
- `20190808142154_replace_product_element_product_layout_tab_with_source.rb`: Improved layout structure
- `20190530211903_rename_kiosk_id_to_store_id_on_customer_order.rb`: Standardized store references
- `20190529224538_add_kiosk_product_to_rfid_products.rb`: Enhanced RFID tracking
- `20190522165456_add_kiosk_id_to_kiosk_products.rb`: Improved kiosk product management
- `20190521180648_rename_store_layout_on_layout_navigation.rb`: Standardized layout naming
- `20190517183537_remove_enabled_share_email_product_from_catalog.rb`: Simplified sharing configuration
- `20190516223630_assign_store_id_to_catalog_sync.rb`: Enhanced store synchronization
- `20190516223600_add_store_to_catalog_sync.rb`: Added store association to catalog sync
- `20190516221327_assign_notification_settings_to_store.rb`: Centralized notification settings
- `20190516215012_add_api_setting_to_store.rb`: Added API configuration
- `20190516192000_assign_store_id_to_rfid_products.rb`: Improved RFID management
- `20190516131212_rename_catalog_product_id_to_store_product.rb`: Standardized product references

## 2018 Migrations

### Store and Layout Management
- `20180925180133_add_override_tags_to_product_variant.rb`: Added tag customization
- `20180824234644_create_customer_order.rb`: Implemented order management
- `20180713172942_add_home_layout_to_store_layouts.rb`: Enhanced layout options
- `20180627023846_create_join_table_catalog_article_catalog_product.rb`: Added article-product relationships
- `20180625142200_add_settings_columns_to_stores.rb`: Extended store configuration
- `20180621143634_add_excerpt_and_icon_to_article.rb`: Enhanced article content
- `20180615193526_move_sync_settings_from_store_to_catalog.rb`: Reorganized sync settings
- `20180404223217_rename_column_name_to_template_in_store_layouts.rb`: Standardized template naming
- `20180404180957_create_store_layouts.rb`: Implemented layout management
- `20180327203814_create_welcome_assets.rb`: Added welcome screen assets
- `20180326141902_add_rfid_to_catalog_products.rb`: Added RFID support
- `20180108184157_create_reviews.rb`: Implemented product reviews

## 2017 Migrations

### Product Management
- `20171221211749_add_index_by_sku_on_variant.rb`: Optimized SKU lookups
- `20171011190637_add_values_to_attribute_def.rb`: Enhanced product attributes
- `20171011142506_add_sku_to_product_variants.rb`: Added SKU tracking
- `20171011140538_remove_code_from_product.rb`: Simplified product structure
- `20170929174923_add_video_url_to_catalog_product.rb`: Added video support
- `20170925193347_add_description_to_product_variants.rb`: Enhanced variant descriptions
- `20170925190209_add_video_url_to_products.rb`: Added product video support

## Key Changes by Category

### Product Management
1. Enhanced product variants with descriptions, SKUs, and tags
2. Added multimedia support (videos)
3. Implemented RFID integration
4. Added weight tracking
5. Improved product synchronization

### Store Configuration
1. Implemented comprehensive store layouts
2. Added tax configuration
3. Enhanced API settings
4. Centralized notification management
5. Improved sync settings

### Customer Experience
1. Added customer favorites
2. Implemented product reviews
3. Enhanced order management
4. Optimized customer data queries
5. Added welcome assets

### Performance Optimizations
1. Added strategic indexes
2. Improved data structure
3. Standardized naming conventions
4. Enhanced relationship management
5. Optimized lookup operations

## Breaking Changes

1. 2022: Dropped store product variants table
2. 2019: Renamed multiple columns for standardization
3. 2018: Moved sync settings from store to catalog
4. 2017: Removed product code field

## Best Practices

1. Always run migrations in sequence
2. Back up data before major structural changes
3. Test migrations in development/staging first
4. Monitor indexes for query optimization
5. Keep migration files focused and atomic 