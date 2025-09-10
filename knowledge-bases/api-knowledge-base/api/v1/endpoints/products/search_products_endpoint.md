# Search Products

## Overview

The Search Products endpoint allows users to search for products by name in the system. This endpoint returns a simplified version of product data, optimized for search results display. The search is performed using a partial match on the product name.

## Endpoint Details

- **URL**: `GET /products/search`
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
| name | string | No | Search term to match against product names (partial match, case insensitive) |
| per_page | integer | No | Number of results to return (default: 15) |
| sort | string | No | Field to sort by (e.g., "name", "created_at") |
| direction | string | No | Sort direction ("asc" or "desc", default: "asc") |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
[
  {
    "id": 123,
    "name": "Premium Yoga Mat",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  },
  {
    "id": 124,
    "name": "Yoga Block",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  },
  {
    "id": 125,
    "name": "Yoga Strap",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  }
]
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
- **Method**: `search`
- **Logic**:
  1. Authorize the user using Pundit policy
  2. Apply name filter if provided
  3. Include category association
  4. Apply sorting
  5. Limit results based on per_page parameter
  6. Return products using the ProductMinimalSerializer

### Model

- **File**: `app/models/product.rb`
- **Scope**:
  - `name_like(name)`: Filters products by name using a partial match

### Policy

- **File**: `app/policies/product_policy.rb`
- **Method**: `search?`
- **Logic**: Returns `user`, allowing any authenticated user to search products

### Serializer

- **File**: `app/serializers/product_minimal_serializer.rb`
- **Attributes**: `id`, `name`
- **Relationships**: `category`

### Database Queries

- Primary query: `SELECT * FROM products JOIN categories ON products.category_id = categories.id WHERE products.name ILIKE '%search_term%' ORDER BY ... LIMIT ...`

## Examples

### Example 1: Basic Search

#### Request

```
GET /products/search?name=yoga
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
[
  {
    "id": 123,
    "name": "Premium Yoga Mat",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  },
  {
    "id": 124,
    "name": "Yoga Block",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  },
  {
    "id": 125,
    "name": "Yoga Strap",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  }
]
```

### Example 2: Search with Sorting and Limit

#### Request

```
GET /products/search?name=yoga&sort=name&direction=desc&per_page=2
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
[
  {
    "id": 125,
    "name": "Yoga Strap",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  },
  {
    "id": 124,
    "name": "Yoga Block",
    "category": {
      "id": 5,
      "name": "Fitness Equipment"
    }
  }
]
```

## Common Use Cases

1. **Product Search**: Allow users to search for products by name
2. **Autocomplete**: Provide suggestions as users type in a search box
3. **Filtered Navigation**: Combine with category filtering for more targeted results
4. **Quick Product Lookup**: Quickly find products without loading full details
5. **Search Results Display**: Show simplified product information in search results

## Related Endpoints

- [Create Product](create_product_endpoint.md): Create a new product
- [Update Product](update_product_endpoint.md): Update an existing product
- [List Products](list_products_endpoint.md): Retrieve a list of products
- [Get Product](get_product_endpoint.md): Retrieve a specific product

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the ProductsController#search method
- Cross-reference with related endpoints to maintain consistency

### Product Management Agent
- Use this endpoint for quick product lookups by name
- Note that this endpoint returns minimal product information compared to the Get Product endpoint
- Results are limited to 15 by default, but this can be adjusted with the per_page parameter

### Integration Agent
- This endpoint is optimized for search functionality
- The response format is an array of products rather than an object with a products key
- No pagination metadata is included in the response

### Content Management Agent
- Use this endpoint to find products by name for content creation
- For detailed product information, follow up with the Get Product endpoint

## Technical Debt and Known Issues

1. **Limited Search Capabilities**: Only searches by product name, not by description or tags
2. **No Fuzzy Matching**: Doesn't support fuzzy matching or typo tolerance
3. **No Pagination Metadata**: Doesn't include pagination metadata in the response
4. **Limited Result Set**: Results are limited to a maximum number of items with no way to page through all results
5. **No Advanced Filtering**: Cannot combine with other filters like category or brand

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-20 | AI Assistant | Initial documentation | 