# API Reference

## Overview

This document provides a comprehensive reference for The Peak Beyond's API, including authentication mechanisms, endpoints, request/response formats, and integration patterns.

## Authentication

### JWT Authentication

The API uses JWT (JSON Web Token) authentication for user access:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Authentication Flow
1. Client sends credentials to `/user_token` endpoint
2. Server validates credentials and returns JWT token
3. Client includes token in `Authorization` header
4. Server validates token for each request

#### JWT Configuration
- Token Lifetime: 100 years (effectively non-expiring)
- Algorithm: HS256
- Secret Key: Rails application secret_key_base

### Store Token Authentication

Used for webhook endpoints from POS systems:

```
X-API-Key: api_key_123456789
```

### Catalog Token Authentication

Used for public API endpoints accessed by kiosks, included as either:
- Query parameter: `?token=catalog_token_123`
- Header: `Authorization: Bearer catalog_token_123`

## API Structure

The API is organized into three main sections:

1. **Administrative API** (`/`): For management interface
2. **Public API** (`/api/v1`): For kiosk frontends
3. **Webhook API** (`/webhooks`): For POS integrations

## Common Headers

```
Content-Type: application/json
Accept: application/json
X-API-Version: 1.0
```

## Common Response Format

### Success Response
```json
{
  "status": "success",
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-03-21T10:00:00Z",
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total_pages": 5,
      "total_count": 100
    }
  }
}
```

### Error Response
```json
{
  "status": "error",
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {
      // Additional error details
    }
  },
  "meta": {
    "timestamp": "2024-03-21T10:00:00Z"
  }
}
```

## Rate Limits

### Administrative API
- 5000 requests per minute per user

### Public API
- 1000 requests per minute per kiosk

Rate limit headers included in responses:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1616321400
```

## Administrative API Endpoints

### Store Management

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/stores` | GET | List all stores | Required |
| `/stores` | POST | Create a new store | Required |
| `/stores/:id` | GET | Get store details | Required |
| `/stores/:id` | PUT | Update store details | Required |
| `/stores/:id/generate_token` | POST | Generate API token | Required |
| `/stores/:id/tax_customer_types` | GET | Get tax customer types | Required |

### User Management

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/users` | GET | List all users | Required |
| `/users` | POST | Create a new user | Required |
| `/users/:id` | GET | Get user details | Required |
| `/users/:id` | PUT | Update user details | Required |
| `/users/current` | GET | Get current user | Required |

### Kiosk Management

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/kiosks` | GET | List all kiosks | Required |
| `/kiosks` | POST | Create a new kiosk | Required |
| `/kiosks/:id` | GET | Get kiosk details | Required |
| `/kiosks/:id` | PUT | Update kiosk details | Required |
| `/kiosks/:id/clone` | POST | Clone a kiosk | Required |

## Public API Endpoints (v1)

### Product Catalog

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/v1/:catalog_id/products` | GET | List products | Optional |
| `/api/v1/:catalog_id/products/:id` | GET | Get product details | Optional |
| `/api/v1/:catalog_id/products/:id/tags` | GET | Get product tags | Optional |
| `/api/v1/:catalog_id/products/:id/reviews` | GET | Get product reviews | Optional |
| `/api/v1/:catalog_id/products/:id/similars` | GET | Get similar products | Optional |

### Order Management

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/v1/:catalog_id/orders` | POST | Create an order | Optional |
| `/api/v1/:catalog_id/orders/:id` | PUT | Update an order | Optional |
| `/api/v1/:catalog_id/orders/status` | PUT | Update order status | Optional |
| `/api/v1/:catalog_id/orders/preview_order` | POST | Preview an order | Optional |
| `/api/v1/:catalog_id/orders/discount` | GET | Get order discount | Optional |

### Cart Management

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/v1/:catalog_id/carts` | GET | List carts | Optional |
| `/api/v1/:catalog_id/carts/validate` | POST | Validate a cart | Optional |
| `/api/v1/:catalog_id/carts/add_items` | POST | Add items to cart | Optional |
| `/api/v1/:catalog_id/carts/update_item` | POST | Update cart item | Optional |
| `/api/v1/:catalog_id/carts/create_or_merge` | POST | Create/merge carts | Optional |

## Webhook API Endpoints

### Treez Webhooks

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/stores/:store_id/webhooks/treez/end_point` | POST | Treez webhook | API Key |

### Shopify Webhooks

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/stores/:store_id/webhooks/shopify/product_create` | POST | Product create | API Key |
| `/stores/:store_id/webhooks/shopify/product_update` | POST | Product update | API Key |
| `/stores/:store_id/webhooks/shopify/product_delete` | POST | Product delete | API Key |
| `/stores/:store_id/webhooks/shopify/order_create` | POST | Order create | API Key |
| `/stores/:store_id/webhooks/shopify/order_update` | POST | Order update | API Key |

### Blaze Webhooks

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/stores/:store_id/webhooks/blaze/end_point` | POST | Blaze webhook | API Key |

## Integration Patterns

### Authentication
- All endpoints require authentication except:
  - Webhook endpoints (use store-specific tokens)
  - Public API endpoints (use catalog-specific tokens)
  - Health check endpoint (`/api/v1/ping`)

### Request/Response Format
- All endpoints use JSON for request/response bodies
- List endpoints support pagination
- Error responses follow consistent format

### Versioning
- Frontend API is versioned (currently v1)
- Administrative API is not versioned

### Multi-tenancy
- Resources are scoped to specific stores
- Tenant isolation enforced through authorization

## Version History
- Initial creation: Comprehensive API reference document
- Added detailed endpoint listings
- Added authentication mechanisms
- Added integration patterns 