# Update Product

## Overview

The Update Product endpoint allows users to modify an existing product's information in the system. This endpoint enables updating various product attributes including name, description, category, tags, and associated media.

## Endpoint Details

- **URL**: `PUT /products/:id`
- **HTTP Method**: PUT
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint
- **API Version**: v1

## Request Headers

| Header Name | Required | Description |
|-------------|----------|-------------|
| Content-Type | Yes | Must be `application/json` |
| Authorization | Yes | Format: "Bearer {token}" |

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | The unique identifier of the product to update |

### Request Body

```json
{
  "product": {
    "name": "string",
    "description": "string",
    "category_id": "integer",
    "tag_list": ["string"],
    "attribute_values_attributes": [
      {
        "id": "integer",
        "attribute_def_id": "integer",
        "value": "string",
        "_destroy": "boolean"
      }
    ],
    "video_attributes": {
      "id": "integer",
      "url": "string",
      "_destroy": "boolean"
    },
    "images_attributes": [
      {
        "id": "integer",
        "url": "string",
        "position": "integer",
        "_destroy": "boolean"
      }
    ],
    "reviews_attributes": [
      {
        "id": "integer",
        "rating": "integer",
        "comment": "string",
        "_destroy": "boolean"
      }
    ]
  }
}
```

All fields are optional for updates. Only include the fields you want to modify.

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "product": {
    "id": 123,
    "name": "Updated Product Name",
    "description": "Updated product description",
    "tag_list": ["tag1", "tag2"],
    "category": {
      "id": 5,
      "name": "Category Name"
    },
    "attribute_values": [
      {
        "id": 42,
        "value": "Value",
        "attribute_def": {
          "id": 7,
          "name": "Attribute Name",
          "attribute_group": {
            "id": 3,
            "name": "Group Name"
          }
        }
      }
    ],
    "video": {
      "id": 12,
      "url": "https://example.com/video.mp4"
    },
    "images": [
      {
        "id": 34,
        "url": "https://example.com/image.jpg",
        "position": 1
      }
    ],
    "reviews": [
      {
        "id": 56,
        "rating": 5,
        "comment": "Great product!"
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

#### 422 Unprocessable Entity

```json
{
  "errors": {
    "name": ["can't be blank"],
    "category_id": ["must exist"]
  }
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/products_controller.rb`
- **Method**: `update`
- **Logic**:
  1. Authorize the user using Pundit policy
  2. Attempt to update the product with permitted attributes
  3. Return the updated product or validation errors

### Model

- **File**: `app/models/product.rb`
- **Validations**:
  - `name` presence is required
  - `category_id` must exist
- **Callbacks**:
  - `before_save :track_tags_changes` - Updates timestamp when tags change

### Policy

- **File**: `app/policies/product_policy.rb`
- **Method**: `update?`
- **Logic**: Returns `user`, allowing any authenticated user to update products

### Serializer

- **File**: `app/serializers/product_serializer.rb`
- **Attributes**: `id`, `name`, `description`, `tag_list`
- **Relationships**: `category`, `attribute_values`, `video`, `images`, `reviews`

### Database Queries

- Primary query: `UPDATE products SET ... WHERE id = ?`
- Associated queries for updating related records (attribute values, images, video, reviews)

## Examples

### Example 1: Update Basic Product Information

#### Request

```
PUT /products/123
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "product": {
    "name": "Updated Yoga Mat",
    "description": "Premium eco-friendly yoga mat with improved grip",
    "tag_list": ["yoga", "fitness", "eco-friendly"]
  }
}
```

#### Response

```json
{
  "product": {
    "id": 123,
    "name": "Updated Yoga Mat",
    "description": "Premium eco-friendly yoga mat with improved grip",
    "tag_list": ["yoga", "fitness", "eco-friendly"],
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    },
    "attribute_values": [...],
    "video": null,
    "images": [...],
    "reviews": [...]
  }
}
```

### Example 2: Update Product with Nested Attributes

#### Request

```
PUT /products/123
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "product": {
    "name": "Premium Yoga Mat",
    "category_id": 6,
    "images_attributes": [
      {
        "id": 34,
        "position": 2
      },
      {
        "url": "https://example.com/new-image.jpg",
        "position": 1
      },
      {
        "id": 35,
        "_destroy": true
      }
    ]
  }
}
```

#### Response

```json
{
  "product": {
    "id": 123,
    "name": "Premium Yoga Mat",
    "description": "Premium eco-friendly yoga mat with improved grip",
    "tag_list": ["yoga", "fitness", "eco-friendly"],
    "category": {
      "id": 6,
      "name": "Premium Fitness"
    },
    "attribute_values": [...],
    "video": null,
    "images": [
      {
        "id": 78,
        "url": "https://example.com/new-image.jpg",
        "position": 1
      },
      {
        "id": 34,
        "url": "https://example.com/image.jpg",
        "position": 2
      }
    ],
    "reviews": [...]
  }
}
```

## Common Use Cases

1. **Product Information Management**: Update product details like name, description, and category
2. **Product Categorization**: Change the category of a product
3. **Product Tagging**: Add or remove tags to improve searchability
4. **Media Management**: Add, update, or remove product images and videos
5. **Attribute Management**: Update product attributes to reflect changes in specifications
6. **Review Management**: Add or update product reviews

## Related Endpoints

- [Create Product](create_product_endpoint.md): Create a new product
- [List Products](list_products_endpoint.md): Retrieve a list of products
- [Get Product](get_product_endpoint.md): Retrieve a specific product
- [Search Products](search_products_endpoint.md): Search for products

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the ProductsController#update method
- Cross-reference with related endpoints to maintain consistency

### Product Management Agent
- Use this endpoint to update product information in the system
- Be aware of validation rules, especially for required fields
- When updating nested attributes, include the `id` for existing records and `_destroy: true` to remove them

### Integration Agent
- This endpoint follows RESTful conventions for updating resources
- Ensure proper error handling for 404 and 422 responses
- Authentication and authorization are required

### Content Management Agent
- Use this endpoint to update product content including descriptions, images, and videos
- Consider updating tags to improve product discoverability

## Technical Debt and Known Issues

1. **No Partial Updates**: The endpoint doesn't support JSON Patch for partial updates
2. **No URL Validation**: URLs for images and videos are not validated
3. **Algolia Indexing Delay**: Updates to products may not be immediately reflected in search results due to Algolia indexing delay
4. **No Bulk Update**: There's no support for updating multiple products at once
5. **No Version History**: Changes to products are not tracked in a version history

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-17 | AI Assistant | Initial documentation | 