# Get Product

## Overview

The Get Product endpoint allows users to retrieve detailed information about a specific product in the system. This endpoint returns comprehensive data including the product's basic information, category, attribute values, images, reviews, and associated video.

## Endpoint Details

- **URL**: `GET /products/:id`
- **HTTP Method**: GET
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint
- **API Version**: v1

## Request Headers

| Header Name | Required | Description |
|-------------|----------|-------------|
| Authorization | Yes | Format: "Bearer {token}" |

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | The unique identifier of the product to retrieve |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "product": {
    "id": 123,
    "name": "Premium Yoga Mat",
    "description": "High-quality eco-friendly yoga mat with superior grip",
    "tag_list": ["yoga", "fitness", "eco-friendly"],
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
      },
      {
        "id": 43,
        "value": "24 inches",
        "attribute_def": {
          "id": 8,
          "name": "Width",
          "attribute_group": {
            "id": 3,
            "name": "Dimensions"
          }
        }
      }
    ],
    "video": {
      "id": 12,
      "url": "https://example.com/videos/premium-yoga-mat.mp4"
    },
    "images": [
      {
        "id": 34,
        "url": "https://example.com/images/premium-yoga-mat-1.jpg"
      },
      {
        "id": 35,
        "url": "https://example.com/images/premium-yoga-mat-2.jpg"
      }
    ],
    "reviews": [
      {
        "id": 56,
        "rating": 5,
        "comment": "Excellent product, highly recommended!"
      },
      {
        "id": 57,
        "rating": 4,
        "comment": "Great quality, but a bit expensive."
      }
    ]
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

#### 404 Not Found

```json
{
  "error": "Couldn't find Product with 'id'=123"
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/products_controller.rb`
- **Method**: `show`
- **Logic**:
  1. Find the product using the `find_product` before_action
  2. Authorize the user using Pundit policy
  3. Return the product with included associations

### Model

- **File**: `app/models/product.rb`
- **Relationships**:
  - `belongs_to :category`
  - `has_many :attribute_values`
  - `has_many :images`
  - `has_many :reviews`
  - `has_one :video`

### Policy

- **File**: `app/policies/product_policy.rb`
- **Method**: `show?`
- **Logic**: Returns `user`, allowing any authenticated user to view product details

### Serializer

- **File**: `app/serializers/product_serializer.rb`
- **Attributes**: `id`, `name`, `description`, `tag_list`
- **Relationships**: `category`, `attribute_values`, `images`, `reviews`, `video`

### Database Queries

- Primary query: `SELECT * FROM products WHERE id = ?`
- Additional queries for included associations:
  - `SELECT * FROM categories WHERE id = ?`
  - `SELECT * FROM attribute_values WHERE product_id = ?`
  - `SELECT * FROM attribute_defs WHERE id IN (?)`
  - `SELECT * FROM attribute_groups WHERE id IN (?)`
  - `SELECT * FROM images WHERE product_id = ?`
  - `SELECT * FROM reviews WHERE product_id = ?`
  - `SELECT * FROM videos WHERE product_id = ?`

## Examples

### Example 1: Basic Product Retrieval

#### Request

```
GET /products/123
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "product": {
    "id": 123,
    "name": "Premium Yoga Mat",
    "description": "High-quality eco-friendly yoga mat with superior grip",
    "tag_list": ["yoga", "fitness", "eco-friendly"],
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
    ],
    "video": null,
    "images": [
      {
        "id": 34,
        "url": "https://example.com/images/premium-yoga-mat-1.jpg"
      }
    ],
    "reviews": []
  }
}
```

## Common Use Cases

1. **Product Detail Display**: Retrieve detailed information about a product for display on a product page
2. **Product Information Management**: Access product details for management and editing purposes
3. **Inventory Management**: Retrieve product information for inventory tracking
4. **Content Management**: Access product details for content creation and marketing
5. **Integration with External Systems**: Retrieve product information for synchronization with other systems

## Related Endpoints

- [Create Product](create_product_endpoint.md): Create a new product
- [Update Product](update_product_endpoint.md): Update an existing product
- [List Products](list_products_endpoint.md): Retrieve a list of products
- [Search Products](search_products_endpoint.md): Search for products

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the ProductsController#show method
- Cross-reference with related endpoints to maintain consistency

### Product Management Agent
- Use this endpoint to retrieve detailed product information for management purposes
- All associated data (attribute values, images, reviews, video) is included in the response

### Integration Agent
- This endpoint follows RESTful conventions for retrieving a specific resource
- Authentication is required for access
- Handle 404 errors appropriately when a product doesn't exist

### Content Management Agent
- Use this endpoint to retrieve comprehensive product information for content creation
- All media assets (images, video) are included in the response

## Technical Debt and Known Issues

1. **No Field Selection**: Cannot specify which fields or associations to include in the response
2. **Performance with Many Associations**: The endpoint may experience performance issues with products that have many associated records
3. **No Caching**: Responses are not cached, which could impact performance for frequently accessed products
4. **No Version History**: Cannot retrieve historical versions of a product
5. **Limited Media Information**: Only basic information about images and videos is provided

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-19 | AI Assistant | Initial documentation | 