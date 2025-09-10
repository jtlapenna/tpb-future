# Repository Analysis Report

## Local Repository: /Users/jeff/AI-agents/cross-repository-new-3-16-25/repositories/back-end

## Directory Structure

```
./
├── .
│   ├── .circleci
│   ├── app
│   │   ├── channels
│   │   │   └── application_cable
│   │   │       ├── channel.rb
│   │   │       └── connection.rb
│   │   ├── contracts
│   │   │   └── cart_contract.rb
│   │   ├── controllers
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       ├── ad_banner_locations_controller.rb
│   │   │   │       ├── ad_banners_controller.rb
│   │   │   │       ├── application_controller.rb
│   │   │   │       ├── brands_controller.rb
│   │   │   │       ├── carts_controller.rb
│   │   │   │       ├── catalog_articles_controller.rb
│   │   │   │       ├── catalogs_controller.rb
│   │   │   │       ├── categories_controller.rb
│   │   │   │       ├── customer_order_controller.rb
│   │   │   │       ├── customers_controller.rb
│   │   │   │       ├── health_controller.rb
│   │   │   │       ├── orders_controller.rb
│   │   │   │       ├── products_controller.rb
│   │   │   │       ├── stores_controller.rb
│   │   │   │       └── users_controller.rb
│   │   │   ├── concerns
│   │   │   │   ├── .keep
│   │   │   │   ├── external_api_bridge.rb
│   │   │   │   ├── kiosk_required.rb
│   │   │   │   ├── paged.rb
│   │   │   │   ├── rescuable.rb
│   │   │   │   ├── searchable.rb
│   │   │   │   └── sortable.rb
│   │   │   ├── webhooks
│   │   │   │   ├── blaze_controller.rb
│   │   │   │   ├── shopify_controller.rb
│   │   │   │   └── treez_controller.rb
│   │   │   ├── ad_configs_controller.rb
│   │   │   ├── application_controller.rb
│   │   │   ├── articles_controller.rb
│   │   │   ├── assets_controller.rb
│   │   │   ├── attribute_defs_controller.rb
│   │   │   ├── attribute_groups_controller.rb
│   │   │   ├── brands_controller.rb
│   │   │   ├── categories_controller.rb
│   │   │   ├── clients_controller.rb
│   │   │   ├── customers_controller.rb
│   │   │   ├── kiosk_brands_controller.rb
│   │   │   ├── kiosk_layouts_controller.rb
│   │   │   ├── kiosk_product_layouts_controller.rb
│   │   │   ├── kiosk_products_controller.rb
│   │   │   ├── kiosks_controller.rb
│   │   │   ├── layout_positions_controller.rb
│   │   │   ├── payment_gateway_providers_controller.rb
│   │   │   ├── payment_gateways_controller.rb
│   │   │   ├── product_layouts_controller.rb
│   │   │   ├── product_variants_controller.rb
│   │   │   ├── products_controller.rb
│   │   │   ├── reviews_controller.rb
│   │   │   ├── rfid_products_controller.rb
│   │   │   ├── store_articles_controller.rb
│   │   │   ├── store_categories_controller.rb
│   │   │   ├── store_category_taxes_controller.rb
│   │   │   ├── store_prices_controller.rb
│   │   │   ├── store_product_promotions_controller.rb
│   │   │   ├── store_products_controller.rb
│   │   │   ├── store_syncs_controller.rb
│   │   │   ├── store_taxes_controller.rb
│   │   │   ├── stores_controller.rb
│   │   │   ├── tag_infos_controller.rb
│   │   │   ├── tags_controller.rb
│   │   │   ├── user_token_controller.rb
│   │   │   └── users_controller.rb
│   │   ├── jobs
│   │   │   ├── application_job.rb
│   │   │   ├── clean_active_carts_job.rb
│   │   │   ├── clean_database_job.rb
│   │   │   ├── create_shopify_webhook_job.rb
│   │   │   ├── customer_sync_job.rb
│   │   │   ├── share_product_text_message_job.rb
│   │   │   └── store_sync_job.rb
│   │   ├── lib
│   │   │   ├── blaze
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── blaze_error.rb
│   │   │   │   ├── customer_client.rb
│   │   │   │   └── order_client.rb
│   │   │   ├── covasoft
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── covasoft_error.rb
│   │   │   │   ├── customer_client.rb
│   │   │   │   └── order_client.rb
│   │   │   ├── ez_texting
│   │   │   │   └── client.rb
│   │   │   ├── flowhub
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── customer_client.rb
│   │   │   │   ├── flowhub_error.rb
│   │   │   │   └── order_client.rb
│   │   │   ├── headset
│   │   │   │   ├── api_client.rb
│   │   │   │   └── headset_error.rb
│   │   │   ├── leaflogix
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── customer_client.rb
│   │   │   │   ├── leaflogix_error.rb
│   │   │   │   └── order_client.rb
│   │   │   ├── shopify
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── order_client.rb
│   │   │   │   └── shopify_error.rb
│   │   │   ├── treez
│   │   │   │   ├── api_client.rb
│   │   │   │   ├── customer.rb
│   │   │   │   ├── customer_client.rb
│   │   │   │   ├── date_validator.rb
│   │   │   │   ├── model.rb
│   │   │   │   ├── order_client.rb
│   │   │   │   └── treez_error.rb
│   │   │   ├── blaze.rb
│   │   │   ├── errors.rb
│   │   │   ├── ez_texting.rb
│   │   │   ├── flowhub.rb
│   │   │   ├── headset.rb
│   │   │   ├── leaflogix.rb
│   │   │   ├── shopify.rb
│   │   │   └── treez.rb
│   │   ├── mailers
│   │   │   ├── api_sync_mailer.rb
│   │   │   ├── application_mailer.rb
│   │   │   ├── orders_mailer.rb
│   │   │   └── products_mailer.rb
│   │   ├── models
│   │   │   ├── concerns
│   │   │   │   ├── .keep
│   │   │   │   ├── external_model.rb
│   │   │   │   ├── reviewable.rb
│   │   │   │   └── union_scope.rb
│   │   │   ├── ad_banner.rb
│   │   │   ├── ad_banner_location.rb
│   │   │   ├── ad_config.rb
│   │   │   ├── application_record.rb
│   │   │   ├── article.rb
│   │   │   ├── asset.rb
│   │   │   ├── asset_element.rb
│   │   │   ├── attribute_def.rb
│   │   │   ├── attribute_group.rb
│   │   │   ├── attribute_value.rb
│   │   │   ├── brand.rb
│   │   │   ├── brand_and_store_category.rb
│   │   │   ├── cart.rb
│   │   │   ├── cart_item.rb
│   │   │   ├── category.rb
│   │   │   ├── client.rb
│   │   │   ├── customer.rb
│   │   │   ├── customer_order.rb
│   │   │   ├── customer_order_store_product.rb
│   │   │   ├── customer_sync.rb
│   │   │   ├── duplicated_sku_deleted_log.rb
│   │   │   ├── expired_kiosk_product.rb
│   │   │   ├── favorite.rb
│   │   │   ├── image.rb
│   │   │   ├── kiosk.rb
│   │   │   ├── kiosk_asset.rb
│   │   │   ├── kiosk_layout.rb
│   │   │   ├── kiosk_product.rb
│   │   │   ├── layout_navigation.rb
│   │   │   ├── layout_navigation_item.rb
│   │   │   ├── layout_position.rb
│   │   │   ├── order.rb
│   │   │   ├── order_customer.rb
│   │   │   ├── order_item.rb
│   │   │   ├── payment_gateway.rb
│   │   │   ├── payment_gateway_provider.rb
│   │   │   ├── product.rb
│   │   │   ├── product_layout.rb
│   │   │   ├── product_layout_element.rb
│   │   │   ├── product_layout_tab.rb
│   │   │   ├── product_layout_value.rb
│   │   │   ├── product_value.rb
│   │   │   ├── product_variant.rb
│   │   │   ├── purchase_limit.rb
│   │   │   ├── review.rb
│   │   │   ├── rfid_product.rb
│   │   │   ├── store.rb
│   │   │   ├── store_article.rb
│   │   │   ├── store_category.rb
│   │   │   ├── store_category_kiosk_layout.rb
│   │   │   ├── store_category_tax.rb
│   │   │   ├── store_price.rb
│   │   │   ├── store_product.rb
│   │   │   ├── store_product_promotion.rb
│   │   │   ├── store_setting.rb
│   │   │   ├── store_sync.rb
│   │   │   ├── store_sync_item.rb
│   │   │   ├── store_tax.rb
│   │   │   ├── tag_info.rb
│   │   │   ├── treez_log.rb
│   │   │   ├── user.rb
│   │   │   ├── video_image_background_asset.rb
│   │   │   └── welcome_asset.rb
│   │   ├── operations
│   │   │   └── clone_kiosk_operation.rb
│   │   ├── parsers
│   │   │   ├── webhooks
│   │   │   │   ├── blaze
│   │   │   │   │   ├── base.rb
│   │   │   │   │   └── store_product.rb
│   │   │   │   ├── shopify
│   │   │   │   │   ├── base.rb
│   │   │   │   │   └── store_product.rb
│   │   │   │   └── treez
│   │   │   │       ├── base.rb
│   │   │   │       ├── customer.rb
│   │   │   │       ├── customer_order.rb
│   │   │   │       └── store_product.rb
│   │   │   ├── blaze_api_parser.rb
│   │   │   ├── covasoft_api_parser.rb
│   │   │   ├── flowhub_api_parser.rb
│   │   │   ├── headset_api_parser.rb
│   │   │   ├── leaflogix_api_parser.rb
│   │   │   ├── product_csv_parser.rb
│   │   │   ├── shopify_api_parser.rb
│   │   │   └── treez_api_parser.rb
│   │   ├── policies
│   │   │   ├── acts_as_taggable_on
│   │   │   │   └── tag_policy.rb
│   │   │   ├── ad_config_policy.rb
│   │   │   ├── application_policy.rb
│   │   │   ├── article_policy.rb
│   │   │   ├── asset_policy.rb
│   │   │   ├── attribute_def_policy.rb
│   │   │   ├── attribute_group_policy.rb
│   │   │   ├── brand_policy.rb
│   │   │   ├── category_policy.rb
│   │   │   ├── client_policy.rb
│   │   │   ├── image_policy.rb
│   │   │   ├── kiosk_layout_policy.rb
│   │   │   ├── kiosk_policy.rb
│   │   │   ├── kiosk_product_layout_policy.rb
│   │   │   ├── kiosk_product_policy.rb
│   │   │   ├── layout_position_policy.rb
│   │   │   ├── product_layout_policy.rb
│   │   │   ├── product_policy.rb
│   │   │   ├── product_variant_policy.rb
│   │   │   ├── review_policy.rb
│   │   │   ├── rfid_product_policy.rb
│   │   │   ├── store_article_policy.rb
│   │   │   ├── store_category_policy.rb
│   │   │   ├── store_category_tax_policy.rb
│   │   │   ├── store_policy.rb
│   │   │   ├── store_price_policy.rb
│   │   │   ├── store_product_policy.rb
│   │   │   ├── store_product_promotion_policy.rb
│   │   │   ├── store_sync_policy.rb
│   │   │   ├── store_tax_policy.rb
│   │   │   ├── tag_info_policy.rb
│   │   │   └── user_policy.rb
│   │   ├── serializers
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       ├── ad_banner_location_serializer.rb
│   │   │   │       ├── ad_banner_serializer.rb
│   │   │   │       ├── asset_element_serializer.rb
│   │   │   │       ├── asset_serializer.rb
│   │   │   │       ├── attribute_value_serializer.rb
│   │   │   │       ├── brand_minimal_serializer.rb
│   │   │   │       ├── brand_serializer.rb
│   │   │   │       ├── category_serializer.rb
│   │   │   │       ├── image_serializer.rb
│   │   │   │       ├── kiosk_asset_serializer.rb
│   │   │   │       ├── kiosk_layout_serializer.rb
│   │   │   │       ├── kiosk_product_minimal_serializer.rb
│   │   │   │       ├── kiosk_product_serializer.rb
│   │   │   │       ├── kiosk_serializer.rb
│   │   │   │       ├── layout_navigation_item_serializer.rb
│   │   │   │       ├── layout_navigation_serializer.rb
│   │   │   │       ├── product_layout_tab_serializer.rb
│   │   │   │       ├── product_layout_value_container_serializer.rb
│   │   │   │       ├── product_layout_value_serializer.rb
│   │   │   │       ├── product_value_serializer.rb
│   │   │   │       ├── review_serializer.rb
│   │   │   │       ├── rfid_product_serializer.rb
│   │   │   │       ├── store_article_serializer.rb
│   │   │   │       ├── store_category_minimal_serializer.rb
│   │   │   │       ├── store_category_serializer.rb
│   │   │   │       ├── store_product_minimal_serializer.rb
│   │   │   │       ├── store_product_serializer.rb
│   │   │   │       ├── store_serializer.rb
│   │   │   │       ├── store_setting_serializer.rb
│   │   │   │       ├── tag_serializer.rb
│   │   │   │       ├── video_image_background_asset_serializer.rb
│   │   │   │       └── welcome_asset_serializer.rb
│   │   │   ├── ad_config_serializer.rb
│   │   │   ├── article_serializer.rb
│   │   │   ├── asset_element_serializer.rb
│   │   │   ├── asset_serializer.rb
│   │   │   ├── attribute_def_serializer.rb
│   │   │   ├── attribute_group_serializer.rb
│   │   │   ├── attribute_value_serializer.rb
│   │   │   ├── brand_minimal_serializer.rb
│   │   │   ├── brand_serializer.rb
│   │   │   ├── catalog_minimal_serializer.rb
│   │   │   ├── category_serializer.rb
│   │   │   ├── client_serializer.rb
│   │   │   ├── image_serializer.rb
│   │   │   ├── kiosk_asset_serializer.rb
│   │   │   ├── kiosk_layout_serializer.rb
│   │   │   ├── kiosk_minimal_serializer.rb
│   │   │   ├── kiosk_product_compact_serializer.rb
│   │   │   ├── kiosk_product_layout_serializer.rb
│   │   │   ├── kiosk_product_minimal_serializer.rb
│   │   │   ├── kiosk_product_serializer.rb
│   │   │   ├── kiosk_serializer.rb
│   │   │   ├── layout_navigation_item_serializer.rb
│   │   │   ├── layout_navigation_serializer.rb
│   │   │   ├── layout_position_serializer.rb
│   │   │   ├── payment_gateway_provider_serializer.rb
│   │   │   ├── payment_gateway_serializer.rb
│   │   │   ├── product_layout_element_serializer.rb
│   │   │   ├── product_layout_serializer.rb
│   │   │   ├── product_layout_tab_serializer.rb
│   │   │   ├── product_layout_value_serializer.rb
│   │   │   ├── product_minimal_serializer.rb
│   │   │   ├── product_serializer.rb
│   │   │   ├── product_value_serializer.rb
│   │   │   ├── product_variant_minimal_serializer.rb
│   │   │   ├── product_variant_serializer.rb
│   │   │   ├── purchase_limit_serializer.rb
│   │   │   ├── review_serializer.rb
│   │   │   ├── rfid_product_serializer.rb
│   │   │   ├── store_article_serializer.rb
│   │   │   ├── store_category_minimal_serializer.rb
│   │   │   ├── store_category_serializer.rb
│   │   │   ├── store_category_tax_serializer.rb
│   │   │   ├── store_minimal_serializer.rb
│   │   │   ├── store_price_serializer.rb
│   │   │   ├── store_product_minimal_serializer.rb
│   │   │   ├── store_product_promotion_serializer.rb
│   │   │   ├── store_product_serializer.rb
│   │   │   ├── store_product_with_values_serializer.rb
│   │   │   ├── store_serializer.rb
│   │   │   ├── store_setting_serializer.rb
│   │   │   ├── store_sync_item_serializer.rb
│   │   │   ├── store_sync_serializer.rb
│   │   │   ├── store_tax_serializer.rb
│   │   │   ├── tag_info_serializer.rb
│   │   │   ├── tag_serializer.rb
│   │   │   ├── user_serializer.rb
│   │   │   ├── version_serializer.rb
│   │   │   ├── video_image_background_asset_serializer.rb
│   │   │   └── welcome_asset_serializer.rb
│   │   ├── services
│   │   └── views
│   │       ├── api_sync_mailer
│   │       │   ├── sync_error.html.erb
│   │       │   └── sync_error.text.erb
│   │       ├── layouts
│   │       │   ├── mailer.html.erb
│   │       │   └── mailer.text.erb
│   │       └── orders_mailer
│   │           ├── new_order.html.erb
│   │           └── new_order.text.erb
│   ├── bin
│   │   ├── rails
│   │   ├── rake
│   │   ├── rspec
│   │   ├── setup
│   │   └── spring
│   ├── config
│   │   ├── environments
│   │   │   ├── development.rb
│   │   │   ├── production.rb
│   │   │   ├── staging.rb
│   │   │   └── test.rb
│   │   ├── initializers
│   │   │   ├── active_model_serializer.rb
│   │   │   ├── acts_as_taggable_on.rb
│   │   │   ├── airbrake.rb
│   │   │   ├── algoliasearch.rb
│   │   │   ├── application_controller_renderer.rb
│   │   │   ├── backtrace_silencers.rb
│   │   │   ├── cors.rb
│   │   │   ├── eager_load_knock.rb
│   │   │   ├── filter_parameter_logging.rb
│   │   │   ├── inflections.rb
│   │   │   ├── kaminari_config.rb
│   │   │   ├── knock.rb
│   │   │   ├── mime_types.rb
│   │   │   ├── oj.rb
│   │   │   ├── pusher.rb
│   │   │   ├── sentry.rb
│   │   │   ├── sidekiq.rb
│   │   │   └── wrap_parameters.rb
│   │   ├── locales
│   │   ├── application.rb
│   │   ├── boot.rb
│   │   ├── database.yml.sample
│   │   ├── environment.rb
│   │   ├── puma.rb
│   │   ├── routes.rb
│   │   └── spring.rb
│   ├── db
│   │   ├── migrate
│   │   │   ├── 20170915193057_initial_imgration.rb
│   │   │   ├── 20170915194440_create_users.rb
│   │   │   ├── 20170919124530_add_description_to_brand.rb
│   │   │   ├── 20170919172250_add_description_to_product.rb
│   │   │   ├── 20170919224551_create_attribute_groups.rb
│   │   │   ├── 20170919225144_create_attribute_defs.rb
│   │   │   ├── 20170919225700_create_attribute_values.rb
│   │   │   ├── 20170922233751_add_type_to_attribute_group.rb
│   │   │   ├── 20170925190209_add_video_url_to_products.rb
│   │   │   ├── 20170925192859_add_video_url_to_product_variants.rb
│   │   │   ├── 20170925193347_add_description_to_product_variants.rb
│   │   │   ├── 20170926145741_create_product_values.rb
│   │   │   ├── 20170928194949_acts_as_taggable_on_migration.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170928194950_add_missing_unique_indices.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170928194951_add_taggings_counter_cache_to_tags.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170928194952_add_missing_taggable_index.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170928194953_change_collation_for_tag_names.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170928194954_add_missing_indexes_on_taggings.acts_as_taggable_on_engine.rb
│   │   │   ├── 20170929174923_add_video_url_to_catalog_product.rb
│   │   │   ├── 20170929175001_add_description_to_catalog_product.rb
│   │   │   ├── 20171002220157_add_active_to_catalog.rb
│   │   │   ├── 20171003140359_add_active_to_user.rb
│   │   │   ├── 20171003170335_add_jti_to_stores.rb
│   │   │   ├── 20171006214139_create_images.rb
│   │   │   ├── 20171009210900_create_join_table_product_variant_image.rb
│   │   │   ├── 20171010143624_create_join_table_catalog_product_image.rb
│   │   │   ├── 20171011140538_remove_code_from_product.rb
│   │   │   ├── 20171011142506_add_sku_to_product_variants.rb
│   │   │   ├── 20171011185000_add_restricted_to_attribute_def.rb
│   │   │   ├── 20171011190637_add_values_to_attribute_def.rb
│   │   │   ├── 20171013173710_add_stock_to_catalog_product.rb
│   │   │   ├── 20171013174901_create_versions.rb
│   │   │   ├── 20171024212632_create_catalog_syncs.rb
│   │   │   ├── 20171024213126_create_catalog_sync_items.rb
│   │   │   ├── 20171025144407_add_state_to_catalog_sync_item.rb
│   │   │   ├── 20171031123637_add_primary_image_to_catalog_product.rb
│   │   │   ├── 20171031141450_add_thumb_image_to_catalog_product.rb
│   │   │   ├── 20171102141247_add_catalog_to_catalog_sync.rb
│   │   │   ├── 20171102210843_add_sku_to_catalog_products.rb
│   │   │   ├── 20171102221351_add_catalog_id_to_catalog_product.rb
│   │   │   ├── 20171109135932_create_catalog_prices.rb
│   │   │   ├── 20171127153201_create_tag_infos.rb
│   │   │   ├── 20171221211749_add_index_by_sku_on_variant.rb
│   │   │   ├── 20180108184157_create_reviews.rb
│   │   │   ├── 20180109134458_add_order_to_attribute_group.rb
│   │   │   ├── 20180122175230_add_set_active_default_on_stores.rb
│   │   │   ├── 20180326141902_add_rfid_to_catalog_products.rb
│   │   │   ├── 20180326153923_create_store_assets.rb
│   │   │   ├── 20180326183214_create_layout_positions.rb
│   │   │   ├── 20180326190204_add_store_id_and_main_to_store_assets.rb
│   │   │   ├── 20180326205655_move_layout_column_from_store_asset_to_store.rb
│   │   │   ├── 20180326213453_create_picture_in_pictures.rb
│   │   │   ├── 20180326221807_create_green_dots.rb
│   │   │   ├── 20180327203814_create_welcome_assets.rb
│   │   │   ├── 20180327204123_remove_column_main_to_store_assets.rb
│   │   │   ├── 20180403145522_change_store_layout_string_to_integer.rb
│   │   │   ├── 20180404180957_create_store_layouts.rb
│   │   │   ├── 20180404183305_remove_layout_from_stores.rb
│   │   │   ├── 20180404183501_change_column_store_id_by_layout_id_in_welcome_asset.rb
│   │   │   ├── 20180404184535_change_column_store_id_by_layout_id_in_store_assets.rb
│   │   │   ├── 20180404223217_rename_column_name_to_template_in_store_layouts.rb
│   │   │   ├── 20180405143637_delete_column_store_layout_id_from_welcome_asset_and_add_to_welcome_asset_id_to_store_layout.rb
│   │   │   ├── 20180405145732_create_asset_elements.rb
│   │   │   ├── 20180405145957_drop_tables_picture_in_pictures_and_green_dots.rb
│   │   │   ├── 20180405182820_create_layouts_for_existent_stores.rb
│   │   │   ├── 20180405215215_add_sync_settings_to_store.rb
│   │   │   ├── 20180409184659_change_column_element_type_to_asset_elements.rb
│   │   │   ├── 20180409220444_create_assets.rb
│   │   │   ├── 20180411132612_catalog_active_default_value.rb
│   │   │   ├── 20180524125725_create_rfid_products.rb
│   │   │   ├── 20180524185011_remove_rfid_from_products.rb
│   │   │   ├── 20180528185723_create_articles.rb
│   │   │   ├── 20180529173232_create_catalog_articles.rb
│   │   │   ├── 20180530173315_add_unique_index_to_catalog_article.rb
│   │   │   ├── 20180613171817_add_client_id_to_users.rb
│   │   │   ├── 20180614041520_add_index_to_attribute_def_name.rb
│   │   │   ├── 20180614050059_add_multi_column_index_to_attribute_value.rb
│   │   │   ├── 20180615193526_move_sync_settings_from_store_to_catalog.rb
│   │   │   ├── 20180618141623_change_sync_settings_to_api_settings.rb
│   │   │   ├── 20180621143634_add_excerpt_and_icon_to_article.rb
│   │   │   ├── 20180625142200_add_settings_columns_to_stores.rb
│   │   │   ├── 20180626224949_create_store_settings.rb
│   │   │   ├── 20180626230538_move_store_general_settings_to_store_settings.rb
│   │   │   ├── 20180626230959_remove_general_settings_from_store.rb
│   │   │   ├── 20180627023846_create_join_table_catalog_article_catalog_product.rb
│   │   │   ├── 20180710204157_create_navigation_layouts.rb
│   │   │   ├── 20180710205210_create_navigation_layout_items.rb
│   │   │   ├── 20180711200930_create_navigation_for_each_store_layout.rb
│   │   │   ├── 20180712163831_change_type_column_secundary_text_to_store_assets.rb
│   │   │   ├── 20180712193410_add_code_to_store_assets.rb
│   │   │   ├── 20180712194302_add_section_position_id_to_store_assets.rb
│   │   │   ├── 20180713172942_add_home_layout_to_store_layouts.rb
│   │   │   ├── 20180719212218_add_title_and_description_to_layout_navigation_item.rb
│   │   │   ├── 20180803213308_add_disabled_rfid_disabled_shopping_to_store_layouts.rb
│   │   │   ├── 20180806142820_rename_columns_disabled_shopping_and_disabled_rfid_to_store_layouts.rb
│   │   │   ├── 20180813143007_add_welcome_message_to_store_layouts.rb
│   │   │   ├── 20180815160024_add_name_index_to_product.rb
│   │   │   ├── 20180824234644_create_customer_order.rb
│   │   │   ├── 20180907152448_rename_column_ticket_id_to_order_id_for_customer_orders.rb
│   │   │   ├── 20180913212932_add_category_product_to_article.rb
│   │   │   ├── 20180918231306_add_catalog_id_to_customer_order.rb
│   │   │   ├── 20180921190109_remove_video_url_field.rb
│   │   │   ├── 20180925180133_add_override_tags_to_product_variant.rb
│   │   │   ├── 20180925183527_add_override_tags_to_catalog_product.rb
│   │   │   ├── 20181025202034_add_order_to_catalog_categories.rb
│   │   │   ├── 20181026205435_add_notification_settings_to_catalog.rb
│   │   │   ├── 20181127183713_add_featured_to_catalog_product.rb
│   │   │   ├── 20181127214123_add_featured_to_catalog.rb
│   │   │   ├── 20181129193408_set_value_default_for_featured_catalog.rb
│   │   │   ├── 20181204212224_add_brand_to_catalog_product.rb
│   │   │   ├── 20190306160208_add_share_email_template_to_catalog_products.rb
│   │   │   ├── 20190307171654_add_enabled_share_email_product_to_catalogs.rb
│   │   │   ├── 20190426230446_add_status_to_catalog_product.rb
│   │   │   ├── 20190426234821_pusblish_all_products.rb
│   │   │   ├── 20190515193251_rename_catalog_category.rb
│   │   │   ├── 20190515195419_rename_catalog_category_on_products.rb
│   │   │   ├── 20190515223013_rename_catalog_price.rb
│   │   │   ├── 20190516125430_rename_catalog_product.rb
│   │   │   ├── 20190516131004_rename_catalog_article_products_join_table.rb
│   │   │   ├── 20190516131212_rename_catalog_product_id_to_store_product.rb
│   │   │   ├── 20190516132231_rename_catalog_product_id_on_rfid_product.rb
│   │   │   ├── 20190516133040_rename_catalog_images_join_table.rb
│   │   │   ├── 20190516133402_rename_catalog_product_id_join_table_column.rb
│   │   │   ├── 20190516174043_add_store_to_store_category.rb
│   │   │   ├── 20190516174337_asign_store_to_store_categories.rb
│   │   │   ├── 20190516175755_update_imageable_types.rb
│   │   │   ├── 20190516182301_remove_caatalog_id_from_store_category.rb
│   │   │   ├── 20190516182700_add_store_id_to_store_product.rb
│   │   │   ├── 20190516183340_assign_store_id_to_store_products.rb
│   │   │   ├── 20190516184159_remove_catalog_id_from_store_products.rb
│   │   │   ├── 20190516191621_add_store_id_to_rfid_products.rb
│   │   │   ├── 20190516191904_remove_catalog_id_from_rfid_products.rb
│   │   │   ├── 20190516192000_assign_store_id_to_rfid_products.rb
│   │   │   ├── 20190516194325_rename_catalog_article_to_store_article.rb
│   │   │   ├── 20190516194650_add_store_to_catalog_article.rb
│   │   │   ├── 20190516194749_assign_store_id_to_store_articles.rb
│   │   │   ├── 20190516195000_remove_catalog_id_from_store_article.rb
│   │   │   ├── 20190516195808_rename_store_articles_products_join_table.rb
│   │   │   ├── 20190516195904_rename_column_store_article_join_table.rb
│   │   │   ├── 20190516215012_add_api_setting_to_store.rb
│   │   │   ├── 20190516215227_assign_api_settings_to_store.rb
│   │   │   ├── 20190516215507_remove_api_settings_from_catalog.rb
│   │   │   ├── 20190516221131_add_notification_settings_to_store.rb
│   │   │   ├── 20190516221327_assign_notification_settings_to_store.rb
│   │   │   ├── 20190516221551_remove_notification_setting_from_catalog.rb
│   │   │   ├── 20190516223600_add_store_to_catalog_sync.rb
│   │   │   ├── 20190516223630_assign_store_id_to_catalog_sync.rb
│   │   │   ├── 20190516223748_remove_catalog_id_from_catalog_sync.rb
│   │   │   ├── 20190516223946_rename_catalog_sync.rb
│   │   │   ├── 20190516224314_rename_catalog_sync_id_on_catalog_sync_item.rb
│   │   │   ├── 20190516224457_rename_catalog_sync_item.rb
│   │   │   ├── 20190517021724_add_store_to_store_price.rb
│   │   │   ├── 20190517021817_assign_store_id_tostore_price.rb
│   │   │   ├── 20190517022023_remove_catalog_id_from_store_price.rb
│   │   │   ├── 20190517142808_add_featured_mode_to_store.rb
│   │   │   ├── 20190517143458_assign_featured_mode_to_stores.rb
│   │   │   ├── 20190517143842_remove_featured_mode_from_catalog.rb
│   │   │   ├── 20190517183308_add_enabled_share_email_product_to_store.rb
│   │   │   ├── 20190517183358_assign_enabled_share_email_product_to_store.rb
│   │   │   ├── 20190517183537_remove_enabled_share_email_product_from_catalog.rb
│   │   │   ├── 20190517221941_move_tags_to_store_product.rb
│   │   │   ├── 20190520202448_rename_catalogs.rb
│   │   │   ├── 20190520214124_rename_catalog_id_on_customer_order.rb
│   │   │   ├── 20190520214722_move_catalog_tags_to_kiosk.rb
│   │   │   ├── 20190521175600_rename_store_layouts.rb
│   │   │   ├── 20190521180648_rename_store_layout_on_layout_navigation.rb
│   │   │   ├── 20190521180912_rename_store_asset.rb
│   │   │   ├── 20190521181003_renaname_store_layout_on_kiosk_asset.rb
│   │   │   ├── 20190521182113_add_kiosk_to_kisk_layout.rb
│   │   │   ├── 20190521182217_assign_kiosk_id_to_kiosk_layouts.rb
│   │   │   ├── 20190521182349_remove_store_from_kiosk_layout.rb
│   │   │   ├── 20190521183029_rename_store_asset_id_on_asset_element.rb
│   │   │   ├── 20190522142656_update_asset_source_type.rb
│   │   │   ├── 20190522163045_create_kiosk_products.rb
│   │   │   ├── 20190522165456_add_kiosk_id_to_kiosk_products.rb
│   │   │   ├── 20190523150207_create_kiosk_products_from_store.rb
│   │   │   ├── 20190529224153_add_kiosk_id_to_rfid_products.rb
│   │   │   ├── 20190529224236_assign_kiosk_id_to_rfid_products.rb
│   │   │   ├── 20190529224538_add_kiosk_product_to_rfid_products.rb
│   │   │   ├── 20190529224614_assign_kiosk_product_id_to_rfid_products.rb
│   │   │   ├── 20190529224920_remove_store_product_id_from_rfid_products.rb
│   │   │   ├── 20190530150828_add_featured_flag_to_kiosk_products.rb
│   │   │   ├── 20190530150907_assign_featured_to_kiosk_products.rb
│   │   │   ├── 20190530151047_remove_featured_from_store_products.rb
│   │   │   ├── 20190530211903_rename_kiosk_id_to_store_id_on_customer_order.rb
│   │   │   ├── 20190604164216_update_valuable_type_on_product_values.rb
│   │   │   ├── 20190614211942_add_data_to_kiosk.rb
│   │   │   ├── 20190619201403_delete_scheduled_catalog_sync_and_schedule_store_sync.rb
│   │   │   ├── 20190628183852_add_auto_add_new_products_to_kiosk.rb
│   │   │   ├── 20190702150438_replace_kiosk_add_new_product_with_product_filter.rb
│   │   │   ├── 20190710174003_change_store_product_default_status.rb
│   │   │   ├── 20190726193710_add_stand_side_to_kiosk_layout.rb
│   │   │   ├── 20190726211444_create_product_layouts.rb
│   │   │   ├── 20190729174150_create_product_layout_tabs.rb
│   │   │   ├── 20190729195034_create_product_layout_elements.rb
│   │   │   ├── 20190731143134_add_product_layout_to_kiosk_layout.rb
│   │   │   ├── 20190801191509_create_product_layout_values.rb
│   │   │   ├── 20190807023611_add_enabled_share_sms_product_to_store.rb
│   │   │   ├── 20190807024735_add_share_sms_template_to_store_product.rb
│   │   │   ├── 20190808030957_add_width_to_product_layout_element.rb
│   │   │   ├── 20190808142154_replace_product_element_product_layout_tab_with_source.rb
│   │   │   ├── 20190808210451_add_stylesheet_to_product_layout.rb
│   │   │   ├── 20190808215404_add_stylesheet_to_kiosk_product.rb
│   │   │   ├── 20190916181632_add_index_incasesensitive_to_brand.rb
│   │   │   ├── 20191011143359_add_screen_type_to_kiosk_layout.rb
│   │   │   ├── 20191111181102_create_customers.rb
│   │   │   ├── 20191111215030_create_customer_syncs.rb
│   │   │   ├── 20191113172408_rename_column_birthdaydate_to_birthday_to_customers.rb
│   │   │   ├── 20191113190555_add_index_customer_id_and_active_to_customers.rb
│   │   │   ├── 20191120183832_add_to_customers_index_by_lower_email.rb
│   │   │   ├── 20191120203751_delete_index_customer_id_and_active_to_customers.rb
│   │   │   ├── 20191120204107_add_store_id_to_customers.rb
│   │   │   ├── 20191120204302_add_index_store_id_and_status_to_customers.rb
│   │   │   ├── 20191121194546_create_purchase_limits.rb
│   │   │   ├── 20191122210103_create_join_table_purchase_limit_store_category.rb
│   │   │   ├── 20191127164310_add_weight_to_store_products.rb
│   │   │   ├── 20191128205152_change_purchase_limit_and_product_weight_to_integer.rb
│   │   │   ├── 20200222010024_add_index_to_customer_phone.rb
│   │   │   ├── 20200222011412_add_api_key_to_customers.rb
│   │   │   ├── 20200222011418_add_api_key_to_customer_syncs.rb
│   │   │   ├── 20200422143126_add_polimorfic_object_to_rfid_product.rb
│   │   │   ├── 20200428141634_update_rfid_product_data.rb
│   │   │   ├── 20200520154023_add_tax_to_stores.rb
│   │   │   ├── 20200520184719_add_tax_to_store_category.rb
│   │   │   ├── 20200521195251_change_tax_into_store.rb
│   │   │   ├── 20200521223533_change_tax_into_store_category.rb
│   │   │   ├── 20200525202824_create_store_taxes.rb
│   │   │   ├── 20200525221918_create_store_category_taxes.rb
│   │   │   ├── 20200710134207_add_rfid_sorting_to_kiosk.rb
│   │   │   ├── 20200918230155_add_rfid_behavior_to_rfid_products.rb
│   │   │   ├── 20201028010058_create_store_product_promotions.rb
│   │   │   ├── 20201028220945_add_home_category_to_kiosk_layouts.rb
│   │   │   ├── 20201030165250_add_home_screen_title_to_kiosk_layouts.rb
│   │   │   ├── 20201222195225_add_nav_ui_to_kiosk_layouts.rb
│   │   │   ├── 20210125204446_add_location_to_kiosk.rb
│   │   │   ├── 20210622231251_create_ad_configs.rb
│   │   │   ├── 20210623152134_create_remove_assets_fields_from_ad_configs.rb
│   │   │   ├── 20210623154408_add_use_brand_spotlight_to_ad_configs.rb
│   │   │   ├── 20210707170948_add_block_simultaneous_nfc_to_stores.rb
│   │   │   ├── 20210831021211_create_favorites.rb
│   │   │   ├── 20210928085723_create_ad_banner_locations.rb
│   │   │   ├── 20210928090111_create_ad_banners.rb
│   │   │   ├── 20210929033533_add_index_to_ad_banner_location.rb
│   │   │   ├── 20211004191721_add_callback_url_to_ad_banners.rb
│   │   │   ├── 20211013071018_create_payment_gateway_providers.rb
│   │   │   ├── 20211013073118_create_payment_gateways.rb
│   │   │   ├── 20211013080646_add_enabled_projects_to_payment_gateways.rb
│   │   │   ├── 20211106155515_add_code_name_to_ad_banner_locations.rb
│   │   │   ├── 20211106161745_add_special_type_to_ad_banner_locations.rb
│   │   │   ├── 20211106165245_add_advertisable_to_ad_banners.rb
│   │   │   ├── 20211106165507_add_disabled_to_ad_banners.rb
│   │   │   ├── 20211210131620_add_webhook_url_to_stores.rb
│   │   │   ├── 20220115053632_change_product_weight_to_decimal.rb
│   │   │   ├── 20220209173044_create_store_product_variants.rb
│   │   │   ├── 20220217174245_drop_table_store_product_variants.rb
│   │   │   ├── 20220318112549_add_latest_update_source_to_store_products.rb
│   │   │   ├── 20220506145820_create_order_customers.rb
│   │   │   ├── 20220506165119_create_customer_order_store_products.rb
│   │   │   ├── 20220705182154_add_order_to_rfid_product.rb
│   │   │   ├── 20220720163537_add_fast_animation_to_kiosk_layouts.rb
│   │   │   ├── 20221004111646_change_default_rfid_order_value.rb
│   │   │   ├── 20221010195833_create_store_category_kiosk_layouts.rb
│   │   │   ├── 20221011092616_add_disable_overlay_mask_tokiosklayouts.rb
│   │   │   ├── 20221026142649_add_column_order_to_store_category_kiosk_layouts.rb
│   │   │   ├── 20221111130215_add_inventory_type_medical_to_store_products.rb
│   │   │   ├── 20221111130227_add_inventory_type_medical_to_store_sync_items.rb
│   │   │   ├── 20221125143304_add_object_changes_to_versions.rb
│   │   │   ├── 20230612163116_add_data_to_customer_orders.rb
│   │   │   ├── 20230614151826_add_printed_date_and_printed_id_to_customer_orders.rb
│   │   │   ├── 20230616201542_add_column_to_customers.rb
│   │   │   ├── 20230620142737_renamelast_modified_date_utc_in_customers.rb
│   │   │   ├── 20231020043003_add_lastest_update_token_to_store_products.rb
│   │   │   ├── 20240305171155_add_promotion_columns_to_store_product_promotions.rb
│   │   │   ├── 20240316000000_create_users.rb
│   │   │   ├── 20240327171141_add_discount_price_to_store_products_promotions_table.rb
│   │   │   ├── 20240523152801_add_has_promotion_to_store_products.rb
│   │   │   ├── 20240612142002_add_sync_columns_to_stores.rb
│   │   │   ├── 20240621144639_add_access_token_to_stores.rb
│   │   │   ├── 20240628154934_create_brand_and_store_categories.rb
│   │   │   ├── 20240802200630_add_last_updated_websocket_to_store_products.rb
│   │   │   ├── 20240819145039_add_is_medical_only_to_store_products.rb
│   │   │   ├── 20240821174131_create_duplicated_sku_deleted_logs.rb
│   │   │   ├── 20240822221120_create_expired_kiosk_products.rb
│   │   │   ├── 20240917164137_add_discount_type_to_store_product_promotions.rb
│   │   │   ├── 20241017154812_create_carts.rb
│   │   │   ├── 20241017155603_create_cart_items.rb
│   │   │   ├── 20241019155933_add_store_product_id_to_cart_items.rb
│   │   │   ├── 20241019161124_remove_product_id_from_cart_items.rb
│   │   │   ├── 20241019171748_add_index_to_carts_updated_at.rb
│   │   │   ├── 20241022184026_add_enabled_continuous_cart_to_store.rb
│   │   │   ├── 20241126213758_add_is_full_screen_video_to_store_products.rb
│   │   │   ├── 20241202230040_create_video_image_background_assets.rb
│   │   │   └── 20241202230146_add_video_image_background_asset_to_kiosk_layouts.rb
│   │   ├── schema.rb
│   │   └── seeds.rb
│   ├── docs
│   │   ├── api
│   │   ├── configurations
│   │   │   └── api
│   │   └── peak_api.md
│   ├── lib
│   │   └── tasks
│   │       ├── .keep
│   │       ├── ad_banner_locations.rake
│   │       ├── adjust_type_field.rake
│   │       ├── application.rake
│   │       ├── auto_annotate_models.rake
│   │       ├── back_populate_store.rake
│   │       ├── docs.rake
│   │       ├── set_image.rake
│   │       ├── shopify.rake
│   │       └── sidekiq.rake
│   ├── log
│   │   └── .keep
│   ├── mdc_output
│   │   ├── dependency_graph.gexf
│   │   ├── directory_structure.txt
│   │   └── repo_analysis_report.md
│   ├── public
│   │   ├── index.html
│   │   └── robots.txt
│   ├── redis
│   │   ├── Dockerfile
│   │   ├── init.sh
│   │   └── redis.conf
│   ├── repositories
│   │   ├── back-end
│   │   ├── cms-fe-angular
│   │   └── front-end
│   ├── spec
│   │   ├── acceptance
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       ├── health_spec.rb
│   │   │   │       └── users_spec.rb
│   │   │   ├── brands_spec.rb
│   │   │   ├── carts_spec.rb
│   │   │   ├── catalog_articles_spec.rb
│   │   │   ├── catalogs_spec.rb
│   │   │   ├── categories_spec.rb
│   │   │   ├── customers_spec.rb
│   │   │   ├── orders_spec.rb
│   │   │   ├── products_spec.rb
│   │   │   └── stores_spec.rb
│   │   ├── controllers
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       ├── application_controller_spec.rb
│   │   │   │       ├── carts_controller_spec.rb
│   │   │   │       ├── catalog_articles_controller_spec.rb
│   │   │   │       ├── catalogs_controller_spec.rb
│   │   │   │       ├── customers_controller_spec.rb
│   │   │   │       ├── health_controller_spec.rb
│   │   │   │       ├── orders_controller_spec.rb
│   │   │   │       ├── products_controller_spec.rb
│   │   │   │       └── users_controller_spec.rb
│   │   │   ├── articles_controller_spec.rb
│   │   │   ├── assets_controller_spec.rb
│   │   │   ├── attribute_defs_controller_spec.rb
│   │   │   ├── attribute_groups_controller_spec.rb
│   │   │   ├── brands_controller_spec.rb
│   │   │   ├── categories_controller_spec.rb
│   │   │   ├── clients_controller_spec.rb
│   │   │   ├── kiosk_product_layouts_controller_spec.rb
│   │   │   ├── kiosk_products_controller_spec.rb
│   │   │   ├── kiosks_controller_spec.rb
│   │   │   ├── product_layouts_controller_spec.rb
│   │   │   ├── product_variants_controller_spec.rb
│   │   │   ├── products_controller_spec.rb
│   │   │   ├── reviews_controller_spec.rb
│   │   │   ├── rfid_products_controller_spec.rb
│   │   │   ├── secured_controller_spec.rb
│   │   │   ├── store_articles_controller_spec.rb
│   │   │   ├── store_categories_controller_spec.rb
│   │   │   ├── store_prices_controller_spec.rb
│   │   │   ├── store_products_controller_spec.rb
│   │   │   ├── store_syncs_controller_spec.rb
│   │   │   ├── stores_controller_spec.rb
│   │   │   ├── tag_infos_controller_spec.rb
│   │   │   ├── tags_controller_spec.rb
│   │   │   ├── user_token_controller_spec.rb
│   │   │   └── users_controller_spec.rb
│   │   ├── factories
│   │   │   ├── ad_configs.rb
│   │   │   ├── brand_and_store_categories.rb
│   │   │   ├── cart_items.rb
│   │   │   ├── carts.rb
│   │   │   ├── customer_order_store_products.rb
│   │   │   ├── customer_syncs.rb
│   │   │   ├── customers.rb
│   │   │   ├── duplicated_sku_deleted_logs.rb
│   │   │   ├── expired_kiosk_products.rb
│   │   │   ├── factories.rb
│   │   │   ├── order_customers.rb
│   │   │   ├── payment_gateway_providers.rb
│   │   │   ├── payment_gateways.rb
│   │   │   ├── store_category_kiosk_layouts.rb
│   │   │   ├── store_category_taxes.rb
│   │   │   ├── store_product_promotions.rb
│   │   │   ├── store_taxes.rb
│   │   │   └── users.rb
│   │   ├── jobs
│   │   │   ├── customer_sync_job_spec.rb
│   │   │   ├── share_product_text_message_job_spec.rb
│   │   │   └── store_sync_job_spec.rb
│   │   ├── lib
│   │   │   ├── covasoft
│   │   │   │   └── api_client_spec.rb
│   │   │   ├── ez_texting
│   │   │   │   └── client_spec.rb
│   │   │   ├── flowhub
│   │   │   │   ├── api_client_spec.rb
│   │   │   │   ├── customer_client_spec.rb
│   │   │   │   └── order_client_spec.rb
│   │   │   ├── headset
│   │   │   │   └── api_client_spec.rb
│   │   │   ├── leaflogix
│   │   │   │   ├── api_client_spec.rb
│   │   │   │   ├── customer_client_spec.rb
│   │   │   │   └── order_client_spec.rb
│   │   │   └── treez
│   │   │       ├── api_client_spec.rb
│   │   │       ├── customer_client_spec.rb
│   │   │       ├── customer_spec.rb
│   │   │       └── order_client_spec.rb
│   │   ├── mailers
│   │   │   ├── api_sync_spec.rb
│   │   │   ├── orders_spec.rb
│   │   │   └── products_spec.rb
│   │   ├── models
│   │   │   ├── ad_config_spec.rb
│   │   │   ├── article_spec.rb
│   │   │   ├── asset_element_spec.rb
│   │   │   ├── asset_spec.rb
│   │   │   ├── attribute_def_spec.rb
│   │   │   ├── attribute_group_spec.rb
│   │   │   ├── attribute_value_spec.rb
│   │   │   ├── brand_and_store_category_spec.rb
│   │   │   ├── brand_spec.rb
│   │   │   ├── cart_item_spec.rb
│   │   │   ├── cart_spec.rb
│   │   │   ├── catalog_price_spec.rb
│   │   │   ├── category_spec.rb
│   │   │   ├── client_spec.rb
│   │   │   ├── customer_order_spec.rb
│   │   │   ├── customer_order_store_product_spec.rb
│   │   │   ├── customer_spec.rb
│   │   │   ├── customer_sync_spec.rb
│   │   │   ├── duplicated_sku_deleted_log_spec.rb
│   │   │   ├── expired_kiosk_product_spec.rb
│   │   │   ├── image_spec.rb
│   │   │   ├── kiosk_asset_spec.rb
│   │   │   ├── kiosk_layout_spec.rb
│   │   │   ├── kiosk_product_spec.rb
│   │   │   ├── kiosk_spec.rb
│   │   │   ├── layout_navigation_item_spec.rb
│   │   │   ├── layout_navigation_spec.rb
│   │   │   ├── layout_position_spec.rb
│   │   │   ├── order_customer_spec.rb
│   │   │   ├── order_item_spec.rb
│   │   │   ├── order_spec.rb
│   │   │   ├── payment_gateway_provider_spec.rb
│   │   │   ├── payment_gateway_spec.rb
│   │   │   ├── product_layout_element_spec.rb
│   │   │   ├── product_layout_spec.rb
│   │   │   ├── product_layout_tab_spec.rb
│   │   │   ├── product_layout_value_spec.rb
│   │   │   ├── product_spec.rb
│   │   │   ├── product_value_spec.rb
│   │   │   ├── product_variant_spec.rb
│   │   │   ├── purchase_limit_spec.rb
│   │   │   ├── review_spec.rb
│   │   │   ├── rfid_product_spec.rb
│   │   │   ├── store_article_spec.rb
│   │   │   ├── store_category_kiosk_layout_spec.rb
│   │   │   ├── store_category_spec.rb
│   │   │   ├── store_category_tax_spec.rb
│   │   │   ├── store_product_promotion_spec.rb
│   │   │   ├── store_product_spec.rb
│   │   │   ├── store_setting_spec.rb
│   │   │   ├── store_spec.rb
│   │   │   ├── store_sync_item_spec.rb
│   │   │   ├── store_sync_spec.rb
│   │   │   ├── store_tax_spec.rb
│   │   │   ├── tag_info_spec.rb
│   │   │   ├── tag_spec.rb
│   │   │   ├── user_spec.rb
│   │   │   └── welcome_asset_spec.rb
│   │   ├── operations
│   │   │   └── clone_kiosk_operations_spec.rb
│   │   ├── parsers
│   │   │   ├── covasoft_api_parser_spec.rb
│   │   │   ├── flowhub_api_parser_spec.rb
│   │   │   ├── headset_api_parser_spec.rb
│   │   │   ├── leaflogix_api_parser_spec.rb
│   │   │   ├── product_csv_parser_spec.rb
│   │   │   └── treez_api_parser_spec.rb
│   │   ├── policies
│   │   │   ├── acts_as_taggable_on
│   │   │   │   └── tag_policy_spec.rb
│   │   │   ├── article_policy_spec.rb
│   │   │   ├── asset_policy_spec.rb
│   │   │   ├── attribute_def_policy_spec.rb
│   │   │   ├── attribute_group_policy_spec.rb
│   │   │   ├── brand_policy_spec.rb
│   │   │   ├── catalog_article_policy_spec.rb
│   │   │   ├── catalog_price_policy_spec.rb
│   │   │   ├── category_policy_spec.rb
│   │   │   ├── client_policy_spec.rb
│   │   │   ├── image_policy_spec.rb
│   │   │   ├── kiosk_layout_policy_spec.rb
│   │   │   ├── kiosk_policy_spec.rb
│   │   │   ├── kiosk_product_layout_policy_spec.rb
│   │   │   ├── kiosk_product_policy_spec.rb
│   │   │   ├── layout_position_policy_spec.rb
│   │   │   ├── product_layout_policy_spec.rb
│   │   │   ├── product_policy_spec.rb
│   │   │   ├── product_variant_policy_spec.rb
│   │   │   ├── review_policy_spec.rb
│   │   │   ├── rfid_product_policy_spec.rb
│   │   │   ├── store_category_policy_spec.rb
│   │   │   ├── store_category_tax_policy_spec.rb
│   │   │   ├── store_policy_spec.rb
│   │   │   ├── store_product_policy_spec.rb
│   │   │   ├── store_sync_policy_spec.rb
│   │   │   ├── store_tax_policy_spec.rb
│   │   │   ├── tag_info_policy_spec.rb
│   │   │   └── user_policy_spec.rb
│   │   ├── requests
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       ├── brands_spec.rb
│   │   │   │       ├── carts_spec.rb
│   │   │   │       ├── catalog_articles_spec.rb
│   │   │   │       ├── catalogs_spec.rb
│   │   │   │       ├── categories_spec.rb
│   │   │   │       ├── customers_spec.rb
│   │   │   │       ├── orders_spec.rb
│   │   │   │       ├── products_spec.rb
│   │   │   │       ├── products_updated_at_spec.rb
│   │   │   │       └── stores_spec.rb
│   │   │   ├── ad_config_request_spec.rb
│   │   │   ├── articles_spec.rb
│   │   │   ├── assets_spec.rb
│   │   │   ├── attribute_defs_spec.rb
│   │   │   ├── attribute_groups_spec.rb
│   │   │   ├── brands_spec.rb
│   │   │   ├── carts_request_spec.rb
│   │   │   ├── categories_spec.rb
│   │   │   ├── clients_spec.rb
│   │   │   ├── customer_order_spec.rb
│   │   │   ├── kiosk_brands_request_spec.rb
│   │   │   ├── kiosk_layouts_spec.rb
│   │   │   ├── kiosk_product_layouts_spec.rb
│   │   │   ├── kiosk_products_spec.rb
│   │   │   ├── kiosks_spec.rb
│   │   │   ├── payment_gateway_providers_spec.rb
│   │   │   ├── payment_gateways_spec.rb
│   │   │   ├── product_layouts_spec.rb
│   │   │   ├── product_variants_spec.rb
│   │   │   ├── products_spec.rb
│   │   │   ├── reviews_spec.rb
│   │   │   ├── rfid_products_spec.rb
│   │   │   ├── store_articles_spec.rb
│   │   │   ├── store_categories_spec.rb
│   │   │   ├── store_category_taxes_spec.rb
│   │   │   ├── store_prices_spec.rb
│   │   │   ├── store_product_promotions_request_spec.rb
│   │   │   ├── store_products_spec.rb
│   │   │   ├── store_syncs_spec.rb
│   │   │   ├── store_taxes_spec.rb
│   │   │   ├── stores_spec.rb
│   │   │   ├── tag_infos_spec.rb
│   │   │   ├── tags_spec.rb
│   │   │   ├── user_tokens_spec.rb
│   │   │   └── users_spec.rb
│   │   ├── routing
│   │   │   ├── payment_gateway_providers_routing_spec.rb
│   │   │   ├── payment_gateways_routing_spec.rb
│   │   │   ├── store_category_taxes_routing_spec.rb
│   │   │   └── store_taxes_routing_spec.rb
│   │   ├── support
│   │   │   ├── api
│   │   │   │   └── v1
│   │   │   │       └── serialization_helper.rb
│   │   │   ├── lib
│   │   │   │   ├── flowhub_api_helper.rb
│   │   │   │   ├── headset_api_helper.rb
│   │   │   │   ├── leaflogix_api_helper.rb
│   │   │   │   └── treez_api_helper.rb
│   │   │   ├── matchers
│   │   │   │   ├── attribute_matcher.rb
│   │   │   │   ├── kiosk_matcher.rb
│   │   │   │   ├── product_matcher.rb
│   │   │   │   └── store_matcher.rb
│   │   │   ├── application_helper.rb
│   │   │   ├── paginated_resources.rb
│   │   │   ├── policies_helpers.rb
│   │   │   ├── request_helper.rb
│   │   │   └── serialization_helper.rb
│   │   ├── acceptance_helper.rb
│   │   ├── rails_helper.rb
│   │   └── spec_helper.rb
│   ├── test
│   ├── tmp
│   │   ├── cache
│   │   │   └── bootsnap
│   │   │       ├── compile-cache-iseq
│   │   │       │   ├── 00
│   │   │       │   │   └── dde653bfcd3f29
│   │   │       │   ├── 01
│   │   │       │   │   ├── 25cc9c3b2f1201
│   │   │       │   │   └── cc305a0095ed9f
│   │   │       │   ├── 04
│   │   │       │   │   └── 5596e3a4d74e15
│   │   │       │   ├── 05
│   │   │       │   │   └── 12e76d26752d79
│   │   │       │   ├── 08
│   │   │       │   │   └── 7aa6da9459d53a
│   │   │       │   ├── 09
│   │   │       │   │   └── 19d85967e79037
│   │   │       │   ├── 0a
│   │   │       │   │   └── b12be0eb0657a0
│   │   │       │   ├── 0b
│   │   │       │   │   └── c19bef74b875ca
│   │   │       │   ├── 0e
│   │   │       │   │   ├── 011e82383a787f
│   │   │       │   │   └── 7f491badab2c2a
│   │   │       │   ├── 11
│   │   │       │   │   └── 021a761274b336
│   │   │       │   ├── 12
│   │   │       │   │   ├── 178162f38e0d01
│   │   │       │   │   ├── 99d547c4824ed1
│   │   │       │   │   └── b94999875c7a80
│   │   │       │   ├── 13
│   │   │       │   │   ├── 9eeb47a5bea2c3
│   │   │       │   │   ├── bd2319366852f5
│   │   │       │   │   └── db415b3c749b40
│   │   │       │   ├── 14
│   │   │       │   │   ├── 00970d0baca1b7
│   │   │       │   │   └── 20547f69eb71ce
│   │   │       │   ├── 16
│   │   │       │   │   └── af5c334263c0d5
│   │   │       │   ├── 1a
│   │   │       │   │   └── 508bb0782ff165
│   │   │       │   ├── 1c
│   │   │       │   │   └── a717f921395bc2
│   │   │       │   ├── 1f
│   │   │       │   │   └── c503982b6eccc2
│   │   │       │   ├── 20
│   │   │       │   │   └── e74278d1a91607
│   │   │       │   ├── 23
│   │   │       │   │   └── 10ef80a448837e
│   │   │       │   ├── 25
│   │   │       │   │   └── b945fdfc608cfa
│   │   │       │   ├── 26
│   │   │       │   │   └── 10273c98ea4568
│   │   │       │   ├── 27
│   │   │       │   │   └── 631253dfdf8737
│   │   │       │   ├── 2a
│   │   │       │   │   └── 4422e2e86b1f75
│   │   │       │   ├── 2b
│   │   │       │   │   └── d55ba0f0bc3465
│   │   │       │   ├── 2c
│   │   │       │   │   └── 9708740d6679b4
│   │   │       │   ├── 2e
│   │   │       │   │   ├── 3c7cd3b7762502
│   │   │       │   │   └── d63bbb4630a37b
│   │   │       │   ├── 2f
│   │   │       │   │   └── ad97ca7fd19ce9
│   │   │       │   ├── 30
│   │   │       │   │   └── 1de0878d44b11e
│   │   │       │   ├── 34
│   │   │       │   │   └── b604917705c0fa
│   │   │       │   ├── 36
│   │   │       │   │   └── cb7e144c0f3d61
│   │   │       │   ├── 37
│   │   │       │   │   ├── 08a3849e683a0a
│   │   │       │   │   └── 0f33111ef3a840
│   │   │       │   ├── 38
│   │   │       │   │   └── 798dba8bc05619
│   │   │       │   ├── 39
│   │   │       │   │   └── abcb4dab3b1285
│   │   │       │   ├── 3c
│   │   │       │   │   └── ac0ed7c0c381ae
│   │   │       │   ├── 3d
│   │   │       │   │   ├── 3a43e0038f3861
│   │   │       │   │   └── 8b65665cebbea6
│   │   │       │   ├── 3e
│   │   │       │   │   └── 5ea4c73b951ef4
│   │   │       │   ├── 41
│   │   │       │   │   └── 9ffe5c3afc5d9f
│   │   │       │   ├── 43
│   │   │       │   │   ├── 4eb8f477527b29
│   │   │       │   │   └── 504c56c38f98e8
│   │   │       │   ├── 44
│   │   │       │   │   ├── 15beae0cd3ee19
│   │   │       │   │   └── 452af5fb8318b1
│   │   │       │   ├── 45
│   │   │       │   │   └── edee4527d1677d
│   │   │       │   ├── 46
│   │   │       │   │   ├── 2cdbc6d94e6e84
│   │   │       │   │   └── a321a5d580742a
│   │   │       │   ├── 47
│   │   │       │   │   └── b01e63e09d628c
│   │   │       │   ├── 48
│   │   │       │   │   └── ce74df8b565e65
│   │   │       │   ├── 49
│   │   │       │   │   └── f2c09d62750ffd
│   │   │       │   ├── 4a
│   │   │       │   │   └── affd2e3708fb90
│   │   │       │   ├── 4d
│   │   │       │   │   └── 6650d2512a1d84
│   │   │       │   ├── 50
│   │   │       │   │   ├── 17ae1f56f0785a
│   │   │       │   │   └── e9fa2fa2988e41
│   │   │       │   ├── 52
│   │   │       │   │   └── 6d068c2b1f521c
│   │   │       │   ├── 53
│   │   │       │   │   ├── 1474f2497b5f64
│   │   │       │   │   └── c746affc4d76c4
│   │   │       │   ├── 56
│   │   │       │   │   └── 734dfe2edbf86d
│   │   │       │   ├── 58
│   │   │       │   │   ├── 3bc280c2d62eb9
│   │   │       │   │   └── cc6b4af021e6f6
│   │   │       │   ├── 5b
│   │   │       │   │   └── ebd0ed81099199
│   │   │       │   ├── 5c
│   │   │       │   │   └── cccebdea6211ea
│   │   │       │   ├── 5f
│   │   │       │   │   └── 444e9bf7ac3760
│   │   │       │   ├── 61
│   │   │       │   │   └── 596b8c17491f54
│   │   │       │   ├── 63
│   │   │       │   │   └── 29fe2d8f0e2dd1
│   │   │       │   ├── 65
│   │   │       │   │   └── 81aac35c6aec04
│   │   │       │   ├── 67
│   │   │       │   │   └── d5d3e2813eb92c
│   │   │       │   ├── 68
│   │   │       │   │   └── 1d8d0966a7f790
│   │   │       │   ├── 69
│   │   │       │   │   └── 150083ce11d287
│   │   │       │   ├── 6a
│   │   │       │   │   └── 51546c1f07c8f7
│   │   │       │   ├── 6c
│   │   │       │   │   └── 08e94dea4313cd
│   │   │       │   ├── 6d
│   │   │       │   │   ├── 3488eb117058a3
│   │   │       │   │   └── baee8c0c11b13e
│   │   │       │   ├── 6e
│   │   │       │   │   └── 8ae00c6fc4c172
│   │   │       │   ├── 6f
│   │   │       │   │   └── 8bbad0b746a1dc
│   │   │       │   ├── 70
│   │   │       │   │   ├── 33ab1f3cda3a0e
│   │   │       │   │   ├── 45e218d5f6349d
│   │   │       │   │   └── b7ea8923cbc51e
│   │   │       │   ├── 73
│   │   │       │   │   ├── 15c7dab7d8e07b
│   │   │       │   │   └── a41bc9364d1931
│   │   │       │   ├── 75
│   │   │       │   │   └── 2347ea404e6cbf
│   │   │       │   ├── 77
│   │   │       │   │   ├── ac5b0137298fce
│   │   │       │   │   └── d9143e00a5c26c
│   │   │       │   ├── 78
│   │   │       │   │   ├── 5318f0c5de10d1
│   │   │       │   │   ├── 69f81fdc04e244
│   │   │       │   │   └── caf8d3321f8349
│   │   │       │   ├── 79
│   │   │       │   │   ├── 18d0ac9e2259af
│   │   │       │   │   ├── cf106218582545
│   │   │       │   │   └── d66d5c54ececae
│   │   │       │   ├── 7b
│   │   │       │   │   └── 01566873334908
│   │   │       │   ├── 7c
│   │   │       │   │   └── 469f1b4112537d
│   │   │       │   ├── 7d
│   │   │       │   │   └── 3b3cc438a3a1b9
│   │   │       │   ├── 80
│   │   │       │   │   └── d2172054082610
│   │   │       │   ├── 81
│   │   │       │   │   └── 9e4a54bdb631bd
│   │   │       │   ├── 84
│   │   │       │   │   └── 8c8593cb53934a
│   │   │       │   ├── 87
│   │   │       │   │   └── 30ce939ead8796
│   │   │       │   ├── 8a
│   │   │       │   │   └── e3439e66cf2763
│   │   │       │   ├── 8b
│   │   │       │   │   └── 829b6ae6616741
│   │   │       │   ├── 8c
│   │   │       │   │   ├── 7b4e2f41ee089c
│   │   │       │   │   └── a7a045786659f0
│   │   │       │   ├── 8d
│   │   │       │   │   ├── 228cac848d49ab
│   │   │       │   │   ├── 54a24bf6a71ca4
│   │   │       │   │   └── f9499ff75dd112
│   │   │       │   ├── 8e
│   │   │       │   │   └── 357ce8a5a2642b
│   │   │       │   ├── 91
│   │   │       │   │   └── a871b9f255314a
│   │   │       │   ├── 92
│   │   │       │   │   └── be2eef725d86b3
│   │   │       │   ├── 93
│   │   │       │   │   ├── 599233b49187fe
│   │   │       │   │   └── e7ae4410895d34
│   │   │       │   ├── 98
│   │   │       │   │   └── d77001734fe44b
│   │   │       │   ├── 9e
│   │   │       │   │   ├── 33e2b481f1330e
│   │   │       │   │   └── 6ef2374b187600
│   │   │       │   ├── 9f
│   │   │       │   │   └── 0caf2f5e2f2d36
│   │   │       │   ├── a1
│   │   │       │   │   └── 26547eec5b56ef
│   │   │       │   ├── a4
│   │   │       │   │   ├── 56d0d2de25b6e6
│   │   │       │   │   └── f37f29f7e54806
│   │   │       │   ├── a5
│   │   │       │   │   └── 46cb995fa4ea27
│   │   │       │   ├── a6
│   │   │       │   │   └── 893b70e90b2cb6
│   │   │       │   ├── a7
│   │   │       │   │   └── b0bca643f239ae
│   │   │       │   ├── aa
│   │   │       │   │   └── 9dc5e6871b382f
│   │   │       │   ├── ab
│   │   │       │   │   └── 56ee2eb000e351
│   │   │       │   ├── ae
│   │   │       │   │   └── acfd8ac1fd6d7d
│   │   │       │   ├── af
│   │   │       │   │   └── 9f8ae1f5523e0d
│   │   │       │   ├── b0
│   │   │       │   │   └── da75241b5e9546
│   │   │       │   ├── b3
│   │   │       │   │   ├── 57512acac2c13b
│   │   │       │   │   ├── 8882e572dea779
│   │   │       │   │   └── 95566972630306
│   │   │       │   ├── b5
│   │   │       │   │   ├── 6b13fabbb5aa93
│   │   │       │   │   └── 7fd1e3ebc77958
│   │   │       │   ├── b7
│   │   │       │   │   └── 1b31364f10bb8c
│   │   │       │   ├── bb
│   │   │       │   │   ├── 789b3c05d44051
│   │   │       │   │   ├── a22664efdf0bae
│   │   │       │   │   └── c6e3a0611bfd0c
│   │   │       │   ├── bc
│   │   │       │   │   └── 5b6e7ec3716aa3
│   │   │       │   ├── bd
│   │   │       │   │   └── 2c330292cb385b
│   │   │       │   ├── bf
│   │   │       │   │   └── 8c6da6ffa9fb48
│   │   │       │   ├── c1
│   │   │       │   │   └── c330e9fe9ac596
│   │   │       │   ├── c2
│   │   │       │   │   ├── 127246377efeba
│   │   │       │   │   └── 6b286bae692ae4
│   │   │       │   ├── c4
│   │   │       │   │   └── 436cd3701eb688
│   │   │       │   ├── c5
│   │   │       │   │   └── 0b256ec8be423e
│   │   │       │   ├── c6
│   │   │       │   │   ├── 200571a93ac3d8
│   │   │       │   │   └── 3267b481aa2c9d
│   │   │       │   ├── c7
│   │   │       │   │   └── 67650487f5a693
│   │   │       │   ├── c8
│   │   │       │   │   └── cb7ce73791775d
│   │   │       │   ├── cb
│   │   │       │   │   └── 8e2d2324327d05
│   │   │       │   ├── cd
│   │   │       │   │   └── be9221508d8da1
│   │   │       │   ├── ce
│   │   │       │   │   └── 156b4f72ee33d1
│   │   │       │   ├── cf
│   │   │       │   │   └── 08e5177f203eaf
│   │   │       │   ├── d3
│   │   │       │   │   └── 22aacce9bf5a3c
│   │   │       │   ├── d6
│   │   │       │   │   └── 7ce04b2b7b706d
│   │   │       │   ├── d7
│   │   │       │   │   └── d0a8fcc362b089
│   │   │       │   ├── d9
│   │   │       │   │   ├── ba756530e9d082
│   │   │       │   │   └── e3b1297412c90c
│   │   │       │   ├── db
│   │   │       │   │   └── a07c8bf5eb06f8
│   │   │       │   ├── dc
│   │   │       │   │   └── 925930cb1e606f
│   │   │       │   ├── dd
│   │   │       │   │   └── 2afe669c17a747
│   │   │       │   ├── de
│   │   │       │   │   └── 3b9f6682667d4a
│   │   │       │   ├── df
│   │   │       │   │   ├── 0b1362de8f5800
│   │   │       │   │   └── f36856112b80e7
│   │   │       │   ├── e0
│   │   │       │   │   ├── 1a930183d84bdc
│   │   │       │   │   └── 4e2fbf84b12460
│   │   │       │   ├── e1
│   │   │       │   │   └── c9a1eafcde0abd
│   │   │       │   ├── e2
│   │   │       │   │   ├── 1cc7f4d2e8fe9b
│   │   │       │   │   └── cc657701eb49c6
│   │   │       │   ├── e3
│   │   │       │   │   └── 6138b60a1d6d81
│   │   │       │   ├── e5
│   │   │       │   │   └── a16cbcca3d5a1f
│   │   │       │   ├── e6
│   │   │       │   │   └── 780edace89eb6c
│   │   │       │   ├── ea
│   │   │       │   │   └── 86b26d0662bb38
│   │   │       │   ├── ed
│   │   │       │   │   └── 06c88b2fda35a9
│   │   │       │   ├── ee
│   │   │       │   │   └── 2fce0cc9678f87
│   │   │       │   ├── ef
│   │   │       │   │   └── c42e092c4b1072
│   │   │       │   ├── f1
│   │   │       │   │   ├── 3218225942be05
│   │   │       │   │   └── ffe280d4e8b957
│   │   │       │   ├── f3
│   │   │       │   │   └── dc84bd007d0728
│   │   │       │   ├── f5
│   │   │       │   │   └── cb74c8a522522a
│   │   │       │   ├── f8
│   │   │       │   │   ├── 7f8d66e168ad75
│   │   │       │   │   └── cb0f479a7680ba
│   │   │       │   ├── fa
│   │   │       │   │   └── 5958be50fc65ef
│   │   │       │   ├── fb
│   │   │       │   │   ├── 1f302c47cbcdd8
│   │   │       │   │   └── 6f2837fdc4255f
│   │   │       │   └── fd
│   │   │       │       └── aac3f9c5b27361
│   │   │       └── load-path-cache
│   │   └── .keep
│   ├── .generators
│   ├── .rakeTasks
│   ├── .rspec
│   ├── .ruby-gemset
│   ├── .ruby-version
│   ├── .simplecov
│   ├── CODE_QUALITY_ANALYSIS.md
│   ├── Dockerfile
│   ├── Dockerfile_Sidekiq
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── Guardfile
│   ├── INTEGRATION_ANALYSIS.md
│   ├── MAINTAINABILITY_ANALYSIS.md
│   ├── PERFORMANCE_ANALYSIS.md
│   ├── Procfile
│   ├── README.md
│   ├── REPOSITORY_ANALYSIS.md
│   ├── RULES_ANALYSIS.md
│   ├── Rakefile
│   ├── SECURITY_ANALYSIS.md
│   ├── TEST_COVERAGE_ANALYSIS.md
│   ├── config.ru
│   ├── entrypoint.sh
│   ├── entrypoint_sidekiq.sh
│   ├── restore_db.sh
│   └── run_sync_job.sh
```

## Code Dependency Graph

- Total files analyzed: 1134
- Total relationships: 0

### Dependency Graph Visualization

Visualization was skipped because PyGraphviz is not installed.
Install with: `pip install mdcgen[visualization]`

### Most Important Files

#### Most Imported Files


#### Files With Most Dependencies




### Most Shared Functions, Classes, and Variables

This section shows individual components (functions, classes, variables) that are imported across multiple files.

#### Most Imported Functions

No functions are imported across files.

#### Most Imported Classes

No classes are imported across files.

#### Most Imported Variables and Constants

No variables or constants are imported across files.

See repo_graph.graphml and repo_graph.json for detailed graph data.

## MDC Documentation Files

Cursor-compatible MDC documentation files have been generated in the `.cursor/rules` directory. These files provide context-aware documentation for:

- Individual files
- Directories
- The entire repository

These files include dependency information and are designed to provide contextual help within the Cursor IDE.

