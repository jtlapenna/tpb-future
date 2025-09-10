---
title: Get Inventory Data
description: API endpoint for retrieving inventory data from Blaze for a store
last_updated: 2023-07-13
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/stores_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/store_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/lib/blaze/api_client.rb
tags:
  - api
  - administrative
  - stores
  - inventory
  - blaze
  - integration
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
  - InventoryManagementAgent
---

# Get Inventory Data

## Overview

This endpoint allows users to retrieve inventory data from the Blaze POS system. The endpoint fetches inventory types from Blaze and filters them to include only active inventory items. This data is useful for configuring and managing inventory in The Peak Beyond's platform.

## Endpoint Details

- **URL**: `POST /stores/:id/get_inventory_data`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Admin users only
- **Rate Limit**: Standard API rate limits apply
- **Integration**: Requires Blaze POS integration

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, must be application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the store | Yes |

### Request Body

```json
{
  "authorization_blaze": "your_blaze_authorization_token",
  "partner_key_blaze": "your_blaze_partner_key"
}
```

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| authorization_blaze | The authorization token for the Blaze API | string | Yes |
| partner_key_blaze | The partner key for the Blaze API | string | Yes |

## Response

### Success Response (200 OK)

```json
[
  {
    "id": "1",
    "name": "Flower",
    "active": true
  },
  {
    "id": "2",
    "name": "Edibles",
    "active": true
  },
  {
    "id": "3",
    "name": "Concentrates",
    "active": true
  }
]
```

The response includes an array of active inventory items, each with the following fields:

| Field | Description | Type |
|-------|-------------|------|
| id | The unique identifier of the inventory type in Blaze | string |
| name | The name of the inventory type | string |
| active | Whether the inventory type is active (always true in the response) | boolean |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=123"}` |
| 422 Unprocessable Entity | Invalid Blaze credentials or other error | `{"message": "Invalid PARTNER or Developer API"}` |
| 500 Internal Server Error | Blaze API error | `{"error": "Blaze API Error: Unauthorized"}` |

## Implementation Details

- **Controller**: `StoresController#get_inventory_data`
- **Model**: `Store`
- **Policy**: `StorePolicy#get_inventory_types?`
- **External API**: `Blaze::ApiClient#get_inventory_types`
- **Database Queries**: 
  - Select query to find the store by ID

### Authorization

The endpoint uses the `StorePolicy#get_inventory_types?` method to determine if the user is authorized to retrieve inventory data. Only admin users are allowed to access this endpoint:

```ruby
def get_inventory_types?
  admin?
end
```

### Integration with Blaze

The endpoint integrates with the Blaze POS system to retrieve inventory data. The integration process involves the following steps:

1. The controller parses the request body to extract the Blaze credentials
2. The controller initializes a Blaze API client with the provided credentials
3. The API client makes a GET request to the Blaze API endpoint `/api/v1/partner/store/inventory/inventories`
4. The API client handles authentication with Blaze using the provided credentials
5. The response from Blaze is filtered to include only active inventory items
6. The filtered inventory items are returned in the response

### Implementation Code

```ruby
def get_inventory_data
  body = JSON.parse(request.body.read).transform_keys(&:to_sym)

  # Fetch inventory data from Blaze
  api_client = Blaze::ApiClient.new(body)
  inventory_data = api_client.get_inventory_types

  # if inventory_data includes :message, return the error message
  if inventory_data.include?(:message)
    render json: { message: inventory_data[:message] }, status: :unprocessable_entity
    return
  end

  # Filter active inventory data
  active_inventory_data = inventory_data
    .select { |inventory_item| inventory_item['active'] == true }
    .map { |inventory_item| { id: inventory_item['id'], name: inventory_item['name'], active: inventory_item['active'] } }

  render json: active_inventory_data, status: :ok
end
```

The `get_inventory_types` method in the Blaze API client makes the API request to Blaze:

```ruby
def get_inventory_types
  response = get(inventory_list_url, headers: auth_headers_blaze)

  if response.ok?
    response_json = response.to_json
    response_parse = JSON.parse response_json

    response_parse["values"]
  else
    Rails.logger.error response.body

    # if error is "message":"Invalid PARTNER or Developer API return message to the user"
    if response.body.include? "Invalid PARTNER or Developer API"
      # return empty array and the message
      return { message: "Invalid PARTNER or Developer API", values: [] }
    end

    raise Blaze::BlazeError, "Blaze API Error: #{response.body}"
  end
end
```

## Examples

### Example Request

```bash
curl -X POST \
  https://api.peakbeyond.com/stores/123e4567-e89b-12d3-a456-426614174000/get_inventory_data \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "authorization_blaze": "your_blaze_authorization_token",
    "partner_key_blaze": "your_blaze_partner_key"
  }'
```

### Example Response

```json
[
  {
    "id": "1",
    "name": "Flower",
    "active": true
  },
  {
    "id": "2",
    "name": "Edibles",
    "active": true
  },
  {
    "id": "3",
    "name": "Concentrates",
    "active": true
  },
  {
    "id": "4",
    "name": "Vaporizers",
    "active": true
  },
  {
    "id": "5",
    "name": "Topicals",
    "active": true
  }
]
```

## Common Use Cases

1. **Inventory Configuration**: Retrieve inventory types to configure inventory settings in The Peak Beyond's platform
2. **Store Setup**: Set up a new store with appropriate inventory types
3. **Integration Verification**: Verify that the Blaze integration is working correctly
4. **Inventory Management**: Use inventory types for inventory management and reporting

## Related Endpoints

- [`GET /stores/:id`](get_store_endpoint.md): Get a specific store
- [`PUT /stores/:id`](update_store_endpoint.md): Update a store
- [`POST /stores/:id/generate_token`](generate_store_token_endpoint.md): Generate API token for a store
- [`GET /stores/:id/tax_customer_types`](tax_customer_types_endpoint.md): Get tax customer types for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The Get Inventory Data endpoint is specific to stores with Blaze POS integration. Make sure to document this requirement.
- **StoreManagementAgent**: This endpoint is useful for configuring inventory settings for a store. The inventory types returned are filtered to include only active types.
- **IntegrationSpecialistAgent**: The endpoint requires Blaze API credentials to be provided in the request body. These credentials are not stored in the system.
- **InventoryManagementAgent**: The inventory types returned by this endpoint are used for inventory configuration. Different inventory types may have different properties and requirements.

## Technical Debt and Known Issues

- The endpoint doesn't validate the request body before attempting to use it, which could lead to unexpected errors.
- The endpoint doesn't use the store's configured Blaze credentials, requiring them to be provided in the request body.
- There's no caching of the inventory types, which means that each request makes a new API call to Blaze.
- The endpoint doesn't handle all possible error cases from the Blaze API, only the "Invalid PARTNER or Developer API" error.
- The endpoint doesn't provide a way to retrieve inactive inventory types, only the active ones.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-13 | Initial documentation | AI Assistant | 