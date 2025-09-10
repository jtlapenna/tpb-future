# List Products

## Overview

The List Products endpoint allows users to retrieve a paginated list of products in the system. This endpoint supports filtering by category, name, and brand, as well as sorting and searching capabilities.

## Endpoint Details

- **URL**: `GET /products`
- **HTTP Method**: GET
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint
- **API Version**: v1

## Request Headers

| Header Name | Required | Description |
|-------------|----------|-------------|
| Authorization | Yes | Format: "Bearer {token}" |

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category_id | integer | No | Filter products by category ID |
| name | string | No | Filter products by name (partial match, case insensitive) |
| brand_id | integer | No | Filter products by brand ID |
| q | string | No | Search query for full-text search |
| page | integer | No | Page number for pagination (default: 1) |
| per_page | integer | No | Number of items per page (default: 25) |
| sort | string | No | Field to sort by (e.g., "name", "created_at") |
| direction | string | No | Sort direction ("asc" or "desc", default: "asc") |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "products": [
    {
      "id": 123,
      "name": "Yoga Mat",
      "description": "Premium eco-friendly yoga mat",
      "tag_list": ["yoga", "fitness"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [
        {
          "id": 42,
          "value": "72 inches",
          "attribute_def": {
            "id": 7,
            "name": "Length",
            "attribute_group": {
              "id": 3,
              "name": "Dimensions"
            }
          }
        }
      ]
    },
    {
      "id": 124,
      "name": "Resistance Bands",
      "description": "Set of 5 resistance bands",
      "tag_list": ["fitness", "strength"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [
        {
          "id": 43,
          "value": "5 pieces",
          "attribute_def": {
            "id": 8,
            "name": "Quantity",
            "attribute_group": {
              "id": 4,
              "name": "Package"
            }
          }
        }
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 125
  }
}
```

### Error Responses

#### 401 Unauthorized

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

#### 403 Forbidden

```json
{
  "error": "You are not authorized to perform this action."
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/products_controller.rb`
- **Method**: `index`
- **Logic**:
  1. Authorize the user using Pundit policy
  2. Apply filters based on query parameters (category_id, name, brand_id)
  3. Apply search if q parameter is present, otherwise apply pagination and sorting
  4. Return the filtered, paginated list of products with pagination metadata

### Model

- **File**: `app/models/product.rb`
- **Relationships**:
  - `belongs_to :category`
  - `has_many :product_variants`
  - `has_many :attribute_values`

### Policy

- **File**: `app/policies/product_policy.rb`
- **Method**: `index?`
- **Logic**: Returns `user`, allowing any authenticated user to list products

### Serializer

- **File**: `app/serializers/product_serializer.rb`
- **Attributes**: `id`, `name`, `description`, `tag_list`
- **Relationships**: `category`, `attribute_values`

### Database Queries

- Primary query: `SELECT * FROM products JOIN categories ON products.category_id = categories.id`
- Additional JOINs for filtering by brand: `JOIN product_variants ON products.id = product_variants.product_id`
- WHERE clauses for filtering by category, name, and brand
- ORDER BY for sorting
- LIMIT and OFFSET for pagination

## Examples

### Example 1: Basic List Request

#### Request

```
GET /products
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "products": [
    {
      "id": 123,
      "name": "Yoga Mat",
      "description": "Premium eco-friendly yoga mat",
      "tag_list": ["yoga", "fitness"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [...]
    },
    {
      "id": 124,
      "name": "Resistance Bands",
      "description": "Set of 5 resistance bands",
      "tag_list": ["fitness", "strength"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [...]
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 125
  }
}
```

### Example 2: Filtered and Sorted List

#### Request

```
GET /products?category_id=5&name=yoga&sort=name&direction=asc&page=1&per_page=10
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "products": [
    {
      "id": 123,
      "name": "Advanced Yoga Mat",
      "description": "Professional-grade yoga mat",
      "tag_list": ["yoga", "professional"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [...]
    },
    {
      "id": 125,
      "name": "Beginner Yoga Mat",
      "description": "Comfortable yoga mat for beginners",
      "tag_list": ["yoga", "beginner"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [...]
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}
```

### Example 3: Search Query

#### Request

```
GET /products?q=eco-friendly
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "products": [
    {
      "id": 123,
      "name": "Yoga Mat",
      "description": "Premium eco-friendly yoga mat",
      "tag_list": ["yoga", "fitness", "eco-friendly"],
      "category": {
        "id": 5,
        "name": "Fitness Equipment"
      },
      "attribute_values": [...]
    },
    {
      "id": 126,
      "name": "Water Bottle",
      "description": "Eco-friendly reusable water bottle",
      "tag_list": ["hydration", "eco-friendly"],
      "category": {
        "id": 6,
        "name": "Accessories"
      },
      "attribute_values": [...]
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}
```

## Common Use Cases

1. **Product Catalog Display**: Retrieve a list of products to display in a catalog or shop
2. **Category Browsing**: Filter products by category to allow users to browse specific sections
3. **Product Search**: Search for products by name or description
4. **Inventory Management**: List products for inventory management purposes
5. **Brand Filtering**: Filter products by brand for brand-specific displays
6. **Pagination**: Navigate through large sets of products using pagination
7. **Sorting**: Sort products by different criteria for different display needs

## Related Endpoints

- [Create Product](create_product_endpoint.md): Create a new product
- [Update Product](update_product_endpoint.md): Update an existing product
- [Get Product](get_product_endpoint.md): Retrieve a specific product
- [Search Products](search_products_endpoint.md): Search for products

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the ProductsController#index method
- Cross-reference with related endpoints to maintain consistency

### Product Management Agent
- Use this endpoint to retrieve lists of products for management purposes
- Leverage filtering, sorting, and pagination for efficient data retrieval
- Consider caching responses for frequently accessed product lists

### Integration Agent
- This endpoint follows RESTful conventions for listing resources
- Pagination metadata is included in the response for proper navigation
- Authentication is required for access

### Content Management Agent
- Use this endpoint to retrieve product information for content creation
- Filter by category or search by keywords to find relevant products
- Sort by name or creation date to organize content workflows

## Technical Debt and Known Issues

1. **Performance with Large Datasets**: The endpoint may experience performance issues with very large product catalogs
2. **Limited Filter Options**: Only category, name, and brand filters are supported
3. **No Advanced Search**: The search functionality is basic and doesn't support advanced queries
4. **No Field Selection**: Cannot specify which fields to include in the response
5. **No Nested Filtering**: Cannot filter by nested attributes (e.g., attribute values)

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-18 | AI Assistant | Initial documentation | 