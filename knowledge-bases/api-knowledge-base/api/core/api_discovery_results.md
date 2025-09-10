---
title: API Discovery Results
description: Comprehensive list of API endpoints identified in The Peak Beyond's backend system
last_updated: 2023-07-11
contributors: [AI Assistant]
related_files:
  - knowledge-base/api/overview.md
  - knowledge-base/technical/api_analysis_approach.md
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/config/routes.rb
tags:
  - api
  - discovery
  - endpoints
ai_agent_relevance:
  - APIDocumentationAgent
  - SystemArchitectAgent
  - IntegrationSpecialistAgent
---

# API Discovery Results

## Overview

This document contains the results of the API discovery process for The Peak Beyond's backend system. It lists all identified API endpoints, organized by category, and provides information about their purpose and authentication requirements.

## API Versions

The system currently supports the following API versions:
- **v1**: The primary API version currently in use

## API Categories

The API endpoints are organized into the following categories:

1. **Administrative API**: Endpoints for managing stores, products, kiosks, and users
2. **Public API**: Endpoints for customer-facing operations
3. **Webhook API**: Endpoints for receiving notifications from external systems
4. **Authentication API**: Endpoints for user authentication
5. **Background Processing API**: Endpoints for managing background jobs

## Administrative API Endpoints

### Store Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/stores` | List all stores | Required |
| POST | `/stores` | Create a new store | Required |
| GET | `/stores/:id` | Get store details | Required |
| PUT | `/stores/:id` | Update store details | Required |
| POST | `/stores/:id/generate_token` | Generate API token for a store | Required |
| GET | `/stores/:id/tax_customer_types` | Get tax customer types for a store | Required |

### Store Sync Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| POST | `/stores/:store_id/store_syncs` | Create a new store sync | Required |
| GET | `/stores/:store_id/store_syncs/:id` | Get store sync details | Required |
| POST | `/stores/:store_id/store_syncs/:id/sync_item` | Sync a specific item | Required |
| PUT | `/stores/:store_id/store_syncs/:id/finish` | Finish a store sync | Required |

### Store Product Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/stores/:store_id/store_products` | List store products | Required |
| POST | `/stores/:store_id/store_products` | Create a store product | Required |
| GET | `/stores/:store_id/store_products/:id` | Get store product details | Required |
| PUT | `/stores/:store_id/store_products/:id` | Update store product | Required |
| DELETE | `/stores/:store_id/store_products/:id` | Delete store product | Required |
| GET | `/stores/:store_id/store_products/search` | Search store products | Required |

### Store Category Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/stores/:store_id/store_categories` | List store categories | Required |
| POST | `/stores/:store_id/store_categories` | Create a store category | Required |
| GET | `/stores/:store_id/store_categories/:id` | Get store category details | Required |
| PUT | `/stores/:store_id/store_categories/:id` | Update store category | Required |
| GET | `/stores/:store_id/store_categories/categories_by_brand` | Get categories by brand | Required |

### Store Article Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/stores/:store_id/articles` | List store articles | Required |
| POST | `/stores/:store_id/articles` | Create a store article | Required |
| GET | `/stores/:store_id/articles/:id` | Get store article details | Required |
| PUT | `/stores/:store_id/articles/:id` | Update store article | Required |
| DELETE | `/stores/:store_id/articles/:id` | Delete store article | Required |
| GET | `/stores/:store_id/articles/default_products` | Get default products for articles | Required |

### Payment Gateway Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/payment_gateway_providers` | List payment gateway providers | Required |
| POST | `/payment_gateway_providers` | Create a payment gateway provider | Required |
| GET | `/payment_gateway_providers/:id` | Get payment gateway provider details | Required |
| PUT | `/payment_gateway_providers/:id` | Update payment gateway provider | Required |
| GET | `/stores/:store_id/payment_gateways` | List payment gateways for a store | Required |
| POST | `/stores/:store_id/payment_gateways` | Create a payment gateway for a store | Required |
| GET | `/stores/:store_id/payment_gateways/:id` | Get payment gateway details | Required |
| PUT | `/stores/:store_id/payment_gateways/:id` | Update payment gateway | Required |

### Kiosk Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/kiosks` | List all kiosks | Required |
| POST | `/kiosks` | Create a new kiosk | Required |
| GET | `/kiosks/:id` | Get kiosk details | Required |
| PUT | `/kiosks/:id` | Update kiosk details | Required |
| POST | `/kiosks/:id/clone` | Clone a kiosk | Required |

### Kiosk Layout Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/kiosks/:kiosk_id/layouts/:id` | Get kiosk layout details | Required |
| PUT | `/kiosks/:kiosk_id/layouts/:id` | Update kiosk layout | Required |

### Kiosk Product Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/kiosks/:kiosk_id/kiosk_products` | List kiosk products | Required |
| POST | `/kiosks/:kiosk_id/kiosk_products` | Create a kiosk product | Required |
| GET | `/kiosks/:kiosk_id/kiosk_products/:id` | Get kiosk product details | Required |
| PUT | `/kiosks/:kiosk_id/kiosk_products/:id` | Update kiosk product | Required |
| DELETE | `/kiosks/:kiosk_id/kiosk_products/:id` | Delete kiosk product | Required |
| GET | `/kiosks/:kiosk_id/kiosk_products/search` | Search kiosk products | Required |
| GET | `/kiosks/:kiosk_id/kiosk_products/compact` | Get compact list of kiosk products | Required |
| GET | `/kiosks/:kiosk_id/kiosk_products/new_categories` | Get new categories for kiosk products | Required |

### RFID Product Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/kiosks/:kiosk_id/rfid_products` | List RFID products | Required |
| POST | `/kiosks/:kiosk_id/rfid_products` | Create an RFID product | Required |
| GET | `/kiosks/:kiosk_id/rfid_products/change_history` | Get RFID product change history | Required |

### Ad Configuration Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/kiosks/:kiosk_id/ad_configs` | List ad configurations | Required |
| POST | `/kiosks/:kiosk_id/ad_configs` | Create an ad configuration | Required |
| GET | `/kiosks/:kiosk_id/ad_configs/:id` | Get ad configuration details | Required |
| PUT | `/kiosks/:kiosk_id/ad_configs/:id` | Update ad configuration | Required |
| DELETE | `/kiosks/:kiosk_id/ad_configs/:id` | Delete ad configuration | Required |

### User Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/users` | List all users | Required |
| POST | `/users` | Create a new user | Required |
| GET | `/users/:id` | Get user details | Required |
| PUT | `/users/:id` | Update user details | Required |
| GET | `/users/current` | Get current user details | Required |

### Product Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/products` | List all products | Required |
| POST | `/products` | Create a new product | Required |
| GET | `/products/:id` | Get product details | Required |
| PUT | `/products/:id` | Update product details | Required |
| GET | `/products/search` | Search products | Required |
| GET | `/products/:id/tags` | Get product tags | Required |

### Product Variant Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/product_variants` | List all product variants | Required |
| POST | `/product_variants` | Create a new product variant | Required |
| GET | `/product_variants/:id` | Get product variant details | Required |
| PUT | `/product_variants/:id` | Update product variant details | Required |
| GET | `/product_variants/search` | Search product variants | Required |
| GET | `/product_variants/:id/tags` | Get product variant tags | Required |

### Brand Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/brands` | List all brands | Required |
| POST | `/brands` | Create a new brand | Required |
| GET | `/brands/:id` | Get brand details | Required |
| PUT | `/brands/:id` | Update brand details | Required |
| GET | `/download_csv` | Download brands CSV | Required |

### Category Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/categories` | List all categories | Required |
| POST | `/categories` | Create a new category | Required |
| GET | `/categories/:id` | Get category details | Required |
| PUT | `/categories/:id` | Update category details | Required |

### Asset Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| DELETE | `/assets/:id` | Delete an asset | Required |
| GET | `/assets/upload_request` | Get asset upload request | Required |

### Review Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/reviews` | List all reviews | Required |
| POST | `/reviews` | Create a new review | Required |
| GET | `/reviews/:id` | Get review details | Required |
| PUT | `/reviews/:id` | Update review details | Required |
| DELETE | `/reviews/:id` | Delete a review | Required |

### Article Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/articles` | List all articles | Required |
| POST | `/articles` | Create a new article | Required |
| GET | `/articles/:id` | Get article details | Required |
| PUT | `/articles/:id` | Update article details | Required |
| DELETE | `/articles/:id` | Delete an article | Required |

## Public API Endpoints (v1)

### Store Information

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/stores/show` | Get store information | Optional |

### Product Catalog

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/stats` | Get API statistics | Optional |
| GET | `/api/v1/ping` | Health check endpoint | None |
| GET | `/api/v1/:catalog_id/products` | List products in a catalog | Optional |
| GET | `/api/v1/:catalog_id/products/:id` | Get product details | Optional |
| GET | `/api/v1/:catalog_id/products/:id/tags` | Get product tags | Optional |
| GET | `/api/v1/:catalog_id/products/:id/reviews` | Get product reviews | Optional |
| GET | `/api/v1/:catalog_id/products/:id/similars` | Get similar products | Optional |
| GET | `/api/v1/:catalog_id/products/minimal` | Get minimal product information | Optional |
| GET | `/api/v1/:catalog_id/products/maximal` | Get maximal product information | Optional |
| GET | `/api/v1/:catalog_id/products/check_products_availability` | Check product availability | Optional |
| POST | `/api/v1/:catalog_id/products/check_products_expired_status` | Check product expired status | Optional |
| POST | `/api/v1/:catalog_id/products/:id/share` | Share a product | Optional |

### Categories and Brands

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/:catalog_id/categories` | List categories in a catalog | Optional |
| GET | `/api/v1/:catalog_id/brands` | List brands in a catalog | Optional |

### Catalog Information

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/:catalog_id/settings` | Get catalog settings | Optional |
| GET | `/api/v1/:catalog_id/tags` | Get catalog tags | Optional |
| GET | `/api/v1/:catalog_id/widgets` | Get catalog widgets | Optional |
| GET | `/api/v1/:catalog_id/rfids` | Get catalog RFID information | Optional |
| GET | `/api/v1/:catalog_id/articles` | Get catalog articles | Optional |

### Customer Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/:catalog_id/customers` | List customers | Required |
| POST | `/api/v1/:catalog_id/customers` | Create a customer | Optional |
| POST | `/customers/search` | Search for customers | Required |

### Order Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/:catalog_id/customer_order` | List customer orders | Required |
| POST | `/api/v1/:catalog_id/customer_order` | Create a customer order | Required |
| PUT | `/api/v1/:catalog_id/customer_order/:id` | Update a customer order | Required |
| POST | `/api/v1/:catalog_id/orders` | Create an order | Optional |
| PUT | `/api/v1/:catalog_id/orders/:id` | Update an order | Optional |
| PUT | `/api/v1/:catalog_id/orders/status` | Update order status | Optional |
| POST | `/api/v1/:catalog_id/orders/preview_order` | Preview an order | Optional |
| GET | `/api/v1/:catalog_id/orders/discount` | Get order discount | Optional |

### Cart Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/:catalog_id/carts` | List carts | Optional |
| POST | `/api/v1/:catalog_id/carts/validate` | Validate a cart | Optional |
| POST | `/api/v1/:catalog_id/carts/add_items` | Add items to a cart | Optional |
| POST | `/api/v1/:catalog_id/carts/update_item` | Update a cart item | Optional |
| POST | `/api/v1/:catalog_id/carts/create_or_merge` | Create or merge carts | Optional |
| GET | `/api/v1/:catalog_id/carts/exists` | Check if a cart exists | Optional |

### Ad Banner Management

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/api/v1/widget-locations` | List ad banner locations | Optional |
| GET | `/api/v1/stores/:store_id/widgets` | List ad banners for a store | Optional |
| POST | `/api/v1/stores/:store_id/widgets` | Create an ad banner for a store | Required |
| GET | `/api/v1/stores/:store_id/widgets/:id` | Get ad banner details | Optional |
| PUT | `/api/v1/stores/:store_id/widgets/:id` | Update ad banner | Required |
| DELETE | `/api/v1/stores/:store_id/widgets/:id` | Delete ad banner | Required |

## Webhook API Endpoints

### Treez Webhooks

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| POST | `/stores/:store_id/webhooks/treez/end_point` | Treez webhook endpoint | API Key |

### Shopify Webhooks

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| POST | `/stores/:store_id/webhooks/shopify/product_create` | Shopify product create webhook | API Key |
| POST | `/stores/:store_id/webhooks/shopify/product_update` | Shopify product update webhook | API Key |
| POST | `/stores/:store_id/webhooks/shopify/product_delete` | Shopify product delete webhook | API Key |
| POST | `/stores/:store_id/webhooks/shopify/order_create` | Shopify order create webhook | API Key |
| POST | `/stores/:store_id/webhooks/shopify/order_update` | Shopify order update webhook | API Key |

### Blaze Webhooks

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| POST | `/stores/:store_id/webhooks/blaze/end_point` | Blaze webhook endpoint | API Key |

## Authentication API Endpoints

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| POST | `/user_token` | Create a user token (login) | None |

## Background Processing API Endpoints

| HTTP Method | Endpoint | Description | Authentication |
|-------------|----------|-------------|----------------|
| GET | `/sidekiq` | Sidekiq web UI | Admin |

## Next Steps

Based on this API discovery, the next steps are:

1. Document the authentication and authorization mechanisms in detail
2. Create detailed documentation for each endpoint, starting with the most critical ones
3. Analyze the implementation details of each endpoint
4. Document common patterns and best practices
5. Identify optimization opportunities

## References

- [routes.rb](thepeakbeyond-aim-tpb-be-7ec9ac972df9/config/routes.rb)
- [API Overview](knowledge-base/api/overview.md)
- [API Analysis Approach](knowledge-base/technical/api_analysis_approach.md) 