---
title: Create Product
description: API endpoint for creating a new product in the system
last_updated: 2023-07-17
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/products_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/product.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/product_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/product_serializer.rb
tags:
  - api
  - administrative
  - products
  - creation
ai_agent_relevance:
  - APIDocumentationAgent
  - ProductManagementAgent
  - IntegrationSpecialistAgent
  - ContentManagementAgent
---

# Create Product

## Overview

This endpoint allows authorized users to create a new product in the system. The product can include basic information such as name, description, and category, as well as associated data like attribute values, images, videos, and reviews. The endpoint supports tagging and full-screen display options.

## Endpoint Details

- **URL**: `POST /products`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Any authenticated user
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, must be application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Request Body

```json
{
  "product": {
    "name": "Premium CBD Oil",
    "description": "High-quality CBD oil with natural ingredients",
    "category_id": "123e4567-e89b-12d3-a456-426614174000",
    "tag_list": ["cbd", "oil", "premium", "natural"],
    "is_full_screen": false,
    "attribute_values_attributes": [
      {
        "attribute_def_id": "223e4567-e89b-12d3-a456-426614174000",
        "value": "30ml"
      },
      {
        "attribute_def_id": "323e4567-e89b-12d3-a456-426614174000",
        "value": "500mg"
      }
    ],
    "video_attributes": {
      "url": "https://example.com/videos/premium-cbd-oil.mp4"
    },
    "images_attributes": [
      {
        "url": "https://example.com/images/premium-cbd-oil-1.jpg"
      },
      {
        "url": "https://example.com/images/premium-cbd-oil-2.jpg"
      }
    ],
    "reviews_attributes": [
      {
        "user": "John Doe",
        "rate": 5,
        "text": "Excellent product, highly recommended!"
      }
    ]
  }
}
```

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| name | The name of the product | string | Yes |
| description | A detailed description of the product | string | No |
| category_id | The ID of the category this product belongs to | string | Yes |
| tag_list | Array of tags to associate with the product | array of strings | No |
| is_full_screen | Whether the product should be displayed in full screen mode | boolean | No |
| attribute_values_attributes | Array of attribute values for the product | array of objects | No |
| video_attributes | Video associated with the product | object | No |
| images_attributes | Array of images associated with the product | array of objects | No |
| reviews_attributes | Array of reviews for the product | array of objects | No |

#### Attribute Values Attributes

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| attribute_def_id | The ID of the attribute definition | string | Yes |
| value | The value of the attribute | string | Yes |

#### Video Attributes

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| url | The URL of the video | string | Yes |

#### Images Attributes

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| url | The URL of the image | string | Yes |

#### Reviews Attributes

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| user | The name of the reviewer | string | Yes |
| rate | The rating given (typically 1-5) | integer | Yes |
| text | The review text | string | No |

## Response

### Success Response (201 Created)

```json
{
  "id": "423e4567-e89b-12d3-a456-426614174000",
  "name": "Premium CBD Oil",
  "description": "High-quality CBD oil with natural ingredients",
  "tag_list": ["cbd", "oil", "premium", "natural"],
  "category": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "CBD Products"
  },
  "video": {
    "id": "523e4567-e89b-12d3-a456-426614174000",
    "url": "https://example.com/videos/premium-cbd-oil.mp4"
  },
  "attribute_values": [
    {
      "id": "623e4567-e89b-12d3-a456-426614174000",
      "attribute_def_id": "223e4567-e89b-12d3-a456-426614174000",
      "value": "30ml"
    },
    {
      "id": "723e4567-e89b-12d3-a456-426614174000",
      "attribute_def_id": "323e4567-e89b-12d3-a456-426614174000",
      "value": "500mg"
    }
  ],
  "images": [
    {
      "id": "823e4567-e89b-12d3-a456-426614174000",
      "url": "https://example.com/images/premium-cbd-oil-1.jpg"
    },
    {
      "id": "923e4567-e89b-12d3-a456-426614174000",
      "url": "https://example.com/images/premium-cbd-oil-2.jpg"
    }
  ],
  "reviews": [
    {
      "id": "a23e4567-e89b-12d3-a456-426614174000",
      "user": "John Doe",
      "rate": 5,
      "text": "Excellent product, highly recommended!"
    }
  ]
}
```

The response includes the newly created product with all its attributes and associated data.

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 422 Unprocessable Entity | Validation errors | `{"errors": {"name": ["can't be blank"], "category_id": ["can't be blank"]}}` |

## Implementation Details

- **Controller**: `ProductsController#create`
- **Model**: `Product`
- **Policy**: `ProductPolicy#create?`
- **Serializer**: `ProductSerializer`
- **Database Queries**: 
  - Insert query to create the product
  - Insert queries for associated attribute values, video, images, and reviews
  - Insert queries for tags

### Authorization

The endpoint uses the `ProductPolicy#create?` method to determine if the user is authorized to create a product. Any authenticated user is allowed to create a product:

```ruby
def create?
  user
end
```

### Validation

The `Product` model includes the following validations:

```ruby
validates :name, presence: true
```

The product must have a name, and the category must exist in the system.

### Implementation Code

```ruby
def create
  authorize(Product)
  product = Product.new(permitted_attributes(Product))

  if product.save
    render json: product, status: :created
  else
    errors = product.errors.as_json
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
```

### Permitted Attributes

The `ProductPolicy` defines the following permitted attributes:

```ruby
def permitted_attributes
  [
    :name, :category_id, :description, :tag_list, :is_full_screen,
    attribute_values_attributes: %i[attribute_def_id value id _destroy],
    video_attributes: %i[id url _destroy],
    images_attributes: %i[id url _destroy],
    reviews_attributes: %i[id user rate text _destroy]
  ]
end
```

## Examples

### Example Request: Create a Basic Product

```bash
curl -X POST \
  https://api.peakbeyond.com/products \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "product": {
      "name": "Basic CBD Oil",
      "description": "Standard CBD oil",
      "category_id": "123e4567-e89b-12d3-a456-426614174000",
      "tag_list": ["cbd", "oil"]
    }
  }'
```

### Example Request: Create a Product with Attributes and Images

```bash
curl -X POST \
  https://api.peakbeyond.com/products \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "product": {
      "name": "Premium CBD Oil",
      "description": "High-quality CBD oil with natural ingredients",
      "category_id": "123e4567-e89b-12d3-a456-426614174000",
      "tag_list": ["cbd", "oil", "premium", "natural"],
      "attribute_values_attributes": [
        {
          "attribute_def_id": "223e4567-e89b-12d3-a456-426614174000",
          "value": "30ml"
        }
      ],
      "images_attributes": [
        {
          "url": "https://example.com/images/premium-cbd-oil-1.jpg"
        }
      ]
    }
  }'
```

## Common Use Cases

1. **Product Catalog Management**: Create new products to expand the product catalog
2. **Product Information Management**: Add detailed product information including attributes, images, and videos
3. **Product Categorization**: Assign products to categories for better organization
4. **Product Tagging**: Add tags to products for improved searchability
5. **Product Reviews**: Add initial reviews to showcase product quality

## Related Endpoints

- [`GET /products`](list_products_endpoint.md): List all products
- [`GET /products/:id`](get_product_endpoint.md): Get a specific product
- [`PUT /products/:id`](update_product_endpoint.md): Update a product
- [`GET /products/search`](search_products_endpoint.md): Search for products

## Notes for AI Agents

- **APIDocumentationAgent**: The Create Product endpoint supports nested attributes for attribute values, videos, images, and reviews. Make sure to document these relationships comprehensively.
- **ProductManagementAgent**: When creating a product, ensure that the category exists in the system. The product will be automatically indexed in Algolia if it's configured.
- **IntegrationSpecialistAgent**: The response includes the full product object with all associated data. This can be used to update the product catalog in integrated systems.
- **ContentManagementAgent**: The endpoint supports adding multiple images and a video to the product. Ensure that the URLs are accessible and the content is appropriate.

## Technical Debt and Known Issues

- The endpoint doesn't validate the URLs for images and videos, which could lead to broken links.
- The endpoint doesn't support bulk creation of products, which could be inefficient for large imports.
- The endpoint doesn't handle duplicate product names, which could lead to confusion.
- The endpoint doesn't support creating product variants directly, requiring a separate API call.
- The Algolia indexing is done asynchronously, which could lead to a delay in search results.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-17 | Initial documentation | AI Assistant | 