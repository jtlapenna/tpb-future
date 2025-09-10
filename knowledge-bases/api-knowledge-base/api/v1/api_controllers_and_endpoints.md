---
title: API Controllers and Endpoints
description: Comprehensive mapping of API controllers and their endpoints
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# API Controllers and Endpoints

## Version Information
- **Category**: API Documentation
- **Type**: Technical Specification
- **Current Version**: 1.0.0
- **Status**: Current
- **Last Updated**: Mar 12, 03:00 PM
- **Last Reviewer**: System
- **Next Review Due**: Apr 12, 2024

## Version History

### Version 1.0.0 - Mar 12, 03:00 PM
- **Author**: System
- **Reviewer**: System
- **Changes**:
  - Initial documentation creation
  - Added controller specifications
  - Included endpoint mappings
  - Documented routing configuration
- **Related Updates**:
  - controller_actions.md - 1.0.0
  - api_documentation_summary.md - 1.0.0

## Dependencies
- **Required By**:
  - controller_actions.md - 1.0.0
  - serializers_overview.md - 1.0.0
- **Depends On**:
  - api_documentation_summary.md - 1.0.0

## Review History
- **Last Review**: Mar 12, 03:00 PM
  - **Reviewer**: System
  - **Outcome**: Approved
  - **Comments**: Initial version approved

## Maintenance Schedule
- **Review Frequency**: Monthly
- **Next Scheduled Review**: Apr 12, 2024
- **Update Window**: First week of each month
- **Quality Assurance**: Technical review and endpoint testing required

## Overview

This document provides a comprehensive mapping of all API controllers and their endpoints in The Peak Beyond's backend system. The API is organized into several categories:

1. **Main API Endpoints**: Standard RESTful endpoints for managing resources
2. **API/V1 Endpoints**: Versioned API endpoints for frontend consumption
3. **Webhook Endpoints**: Endpoints for receiving updates from external systems

## Main API Endpoints

### Store Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoresController | `/stores` | GET | List all stores |
| StoresController | `/stores` | POST | Create a new store |
| StoresController | `/stores/:id` | PUT/PATCH | Update a store |
| StoresController | `/stores/:id` | GET | Get store details |
| StoresController | `/stores/get_inventory_data` | POST | Get inventory data |
| StoresController | `/stores/:id/tax_customer_types` | GET | Get tax customer types |
| StoresController | `/stores/:id/generate_token` | POST | Generate a store token |

### Store Sync Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoreSyncsController | `/stores/:store_id/store_syncs` | POST | Create a store sync |
| StoreSyncsController | `/stores/:store_id/store_syncs/:id` | GET | Get store sync details |
| StoreSyncsController | `/stores/:store_id/store_syncs/:id/sync_item` | POST | Sync a specific item |
| StoreSyncsController | `/stores/:store_id/store_syncs/:id/finish` | PUT | Finish a store sync |

### Store Product Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoreProductsController | `/stores/:store_id/store_products` | GET | List store products |
| StoreProductsController | `/stores/:store_id/store_products` | POST | Create a store product |
| StoreProductsController | `/stores/:store_id/store_products/:id` | PUT/PATCH | Update a store product |
| StoreProductsController | `/stores/:store_id/store_products/:id` | GET | Get store product details |
| StoreProductsController | `/stores/:store_id/store_products/:id` | DELETE | Delete a store product |
| StoreProductsController | `/stores/:store_id/store_products/search` | GET | Search store products |

### Store Product Promotions

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoreProductPromotionsController | `/stores/:store_id/store_products/:store_product_id/store_product_promotions` | GET | List promotions |
| StoreProductPromotionsController | `/stores/:store_id/store_products/:store_product_id/store_product_promotions` | POST | Create a promotion |
| StoreProductPromotionsController | `/stores/:store_id/store_products/:store_product_id/store_product_promotions/:id` | PUT/PATCH | Update a promotion |
| StoreProductPromotionsController | `/stores/:store_id/store_products/:store_product_id/store_product_promotions/:id` | GET | Get promotion details |
| StoreProductPromotionsController | `/stores/:store_id/store_products/:store_product_id/store_product_promotions/:id` | DELETE | Delete a promotion |

### Store Category Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoreCategoriesController | `/stores/:store_id/store_categories` | GET | List store categories |
| StoreCategoriesController | `/stores/:store_id/store_categories` | POST | Create a store category |
| StoreCategoriesController | `/stores/:store_id/store_categories/:id` | PUT/PATCH | Update a store category |
| StoreCategoriesController | `/stores/:store_id/store_categories/:id` | GET | Get store category details |
| StoreCategoriesController | `/stores/:store_id/store_categories/categories_by_brand` | GET | Get categories by brand |

### Store Article Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| StoreArticlesController | `/stores/:store_id/articles` | GET | List store articles |
| StoreArticlesController | `/stores/:store_id/articles` | POST | Create a store article |
| StoreArticlesController | `/stores/:store_id/articles/:id` | PUT/PATCH | Update a store article |
| StoreArticlesController | `/stores/:store_id/articles/:id` | GET | Get store article details |
| StoreArticlesController | `/stores/:store_id/articles/:id` | DELETE | Delete a store article |
| StoreArticlesController | `/stores/:store_id/articles/default_products` | GET | Get default products for articles |

### Kiosk Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| KiosksController | `/kiosks` | GET | List all kiosks |
| KiosksController | `/kiosks` | POST | Create a new kiosk |
| KiosksController | `/kiosks/:id` | PUT/PATCH | Update a kiosk |
| KiosksController | `/kiosks/:id` | GET | Get kiosk details |
| KiosksController | `/kiosks/:id/clone` | POST | Clone a kiosk |

### Kiosk Layout Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| KioskLayoutsController | `/kiosks/:kiosk_id/layouts/:id` | PUT/PATCH | Update a kiosk layout |
| KioskLayoutsController | `/kiosks/:kiosk_id/layouts/:id` | GET | Get kiosk layout details |

### Kiosk Product Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products` | GET | List kiosk products |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products` | POST | Create a kiosk product |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/new` | GET | New kiosk product form |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/:id` | PUT/PATCH | Update a kiosk product |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/:id` | GET | Get kiosk product details |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/:id` | DELETE | Delete a kiosk product |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/search` | GET | Search kiosk products |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/compact` | GET | Get compact list of kiosk products |
| KioskProductsController | `/kiosks/:kiosk_id/kiosk_products/new_categories` | GET | Get new categories for kiosk products |

### RFID Product Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| RfidProductsController | `/kiosks/:kiosk_id/rfid_products` | GET | List RFID products |
| RfidProductsController | `/kiosks/:kiosk_id/rfid_products` | POST | Create an RFID product |
| RfidProductsController | `/kiosks/:kiosk_id/rfid_products/new` | GET | New RFID product form |
| RfidProductsController | `/kiosks/:kiosk_id/rfid_products/change_history` | GET | Get RFID product change history |

### User Management

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| UsersController | `/users` | GET | List all users |
| UsersController | `/users` | POST | Create a new user |
| UsersController | `/users/:id` | PUT/PATCH | Update a user |
| UsersController | `/users/:id` | GET | Get user details |
| UsersController | `/users/current` | GET | Get current user details |

### Authentication

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| UserTokenController | `/user_token` | POST | Create a user token (login) |

## API/V1 Endpoints (Frontend API)

### Application

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::ApplicationController | `/api/v1/stats` | GET | Get API statistics |
| API::V1::ApplicationController | `/api/v1/ping` | GET | Ping the API |

### Catalog Products

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::ProductsController | `/api/v1/:catalog_id/products` | GET | List catalog products |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/:id` | GET | Get catalog product details |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/:id/tags` | GET | Get product tags |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/:id/reviews` | GET | Get product reviews |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/:id/similars` | GET | Get similar products |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/minimal` | GET | Get minimal product list |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/maximal` | GET | Get maximal product list |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/check_products_availability` | GET | Check product availability |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/check_products_expired_status` | POST | Check product expired status |
| API::V1::ProductsController | `/api/v1/:catalog_id/products/:id/share` | POST | Share a product |

### Catalog Categories

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CategoriesController | `/api/v1/:catalog_id/categories` | GET | List catalog categories |

### Catalog Brands

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::BrandsController | `/api/v1/:catalog_id/brands` | GET | List catalog brands |

### Catalog Settings

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CatalogsController | `/api/v1/:catalog_id/settings` | GET | Get catalog settings |
| API::V1::CatalogsController | `/api/v1/:catalog_id/tags` | GET | Get catalog tags |
| API::V1::CatalogsController | `/api/v1/:catalog_id/widgets` | GET | Get catalog widgets |
| API::V1::CatalogsController | `/api/v1/:catalog_id/rfids` | GET | Get catalog RFIDs |

### Catalog Articles

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CatalogArticlesController | `/api/v1/:catalog_id/articles` | GET | List catalog articles |

### Catalog Customers

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CustomersController | `/api/v1/:catalog_id/customers` | GET | List catalog customers |
| API::V1::CustomersController | `/api/v1/:catalog_id/customers` | POST | Create a catalog customer |

### Catalog Orders

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::OrdersController | `/api/v1/:catalog_id/orders` | POST | Create an order |
| API::V1::OrdersController | `/api/v1/:catalog_id/orders/:id` | PUT/PATCH | Update an order |
| API::V1::OrdersController | `/api/v1/:catalog_id/orders/status` | PUT | Update order status |
| API::V1::OrdersController | `/api/v1/:catalog_id/orders/preview_order` | POST | Preview an order |
| API::V1::OrdersController | `/api/v1/:catalog_id/orders/discount` | GET | Get order discount |

### Catalog Carts

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CartsController | `/api/v1/:catalog_id/carts` | GET | List carts |
| API::V1::CartsController | `/api/v1/:catalog_id/carts/validate` | POST | Validate a cart |
| API::V1::CartsController | `/api/v1/:catalog_id/carts/add_items` | POST | Add items to a cart |
| API::V1::CartsController | `/api/v1/:catalog_id/carts/update_item` | POST | Update a cart item |
| API::V1::CartsController | `/api/v1/:catalog_id/carts/create_or_merge` | POST | Create or merge carts |
| API::V1::CartsController | `/api/v1/:catalog_id/carts/exists` | GET | Check if a cart exists |

### Customer Orders

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::CustomerOrderController | `/api/v1/:catalog_id/customer_order` | GET | List customer orders |
| API::V1::CustomerOrderController | `/api/v1/:catalog_id/customer_order` | POST | Create a customer order |
| API::V1::CustomerOrderController | `/api/v1/:catalog_id/customer_order/:id` | PUT/PATCH | Update a customer order |

### Ad Banners and Widgets

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::AdBannerLocationsController | `/api/v1/widget-locations` | GET | List widget locations |
| API::V1::AdBannerLocationsController | `/api/v1/widget-locations` | POST | Create a widget location |
| API::V1::AdBannerLocationsController | `/api/v1/widget-locations/:id` | PUT/PATCH | Update a widget location |
| API::V1::AdBannerLocationsController | `/api/v1/widget-locations/:id` | GET | Get widget location details |
| API::V1::AdBannersController | `/api/v1/stores/:store_id/widgets` | GET | List widgets |
| API::V1::AdBannersController | `/api/v1/stores/:store_id/widgets` | POST | Create a widget |
| API::V1::AdBannersController | `/api/v1/stores/:store_id/widgets/:id` | PUT/PATCH | Update a widget |
| API::V1::AdBannersController | `/api/v1/stores/:store_id/widgets/:id` | GET | Get widget details |

### Store Information

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| API::V1::StoresController | `/api/v1/stores/show` | GET | Get store information |

## Webhook Endpoints

### Treez Webhooks

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| Webhooks::TreezController | `/stores/:store_id/webhooks/treez/end_point` | POST | Treez webhook endpoint |

### Shopify Webhooks

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| Webhooks::ShopifyController | `/stores/:store_id/webhooks/shopify/product_create` | POST | Shopify product create webhook |
| Webhooks::ShopifyController | `/stores/:store_id/webhooks/shopify/product_update` | POST | Shopify product update webhook |
| Webhooks::ShopifyController | `/stores/:store_id/webhooks/shopify/product_delete` | POST | Shopify product delete webhook |
| Webhooks::ShopifyController | `/stores/:store_id/webhooks/shopify/order_create` | POST | Shopify order create webhook |
| Webhooks::ShopifyController | `/stores/:store_id/webhooks/shopify/order_update` | POST | Shopify order update webhook |

### Blaze Webhooks

| Controller | Endpoint | HTTP Method | Description |
|------------|----------|-------------|-------------|
| Webhooks::BlazeController | `/stores/:store_id/webhooks/blaze/end_point` | POST | Blaze webhook endpoint |

## API Integration Patterns

### Authentication

All API endpoints require JWT authentication using the `/user_token` endpoint, except for:
- Webhook endpoints (which use store-specific tokens)
- Public API endpoints (which use catalog-specific tokens)

### Request/Response Format

- All endpoints use JSON for request and response bodies
- List endpoints support pagination with `page` and `per_page` parameters
- Error responses follow a consistent format with appropriate HTTP status codes

### Versioning

- The frontend-facing API is versioned (currently v1)
- The admin API is not versioned

### Multi-tenancy

- Most resources are scoped to a specific store
- The API enforces tenant isolation through authorization policies

## Next Steps

1. Analyze each controller in detail to understand:
   - Request parameters
   - Response formats
   - Authorization rules
   - Business logic

2. Map controllers to serializers to understand:
   - Data transformation
   - Response structure
   - Included associations

3. Document common patterns and conventions across controllers

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial documentation | 