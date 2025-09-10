---
title: Tax Customer Types
description: API endpoint for retrieving tax customer types from Leaflogix for a store
last_updated: 2023-07-13
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/stores_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/store.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/store_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/lib/leaflogix/api_client.rb
tags:
  - api
  - administrative
  - stores
  - tax
  - leaflogix
  - integration
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
  - TaxConfigurationAgent
---

# Tax Customer Types

## Overview

This endpoint allows admin users to retrieve tax customer types from the Leaflogix POS system for a specific store. The endpoint fetches all customer types from Leaflogix and filters them to include only "Recreational" and "Medical" types, which are relevant for tax configuration in The Peak Beyond's platform.

## Endpoint Details

- **URL**: `GET /stores/:id/tax_customer_types`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Admin users only
- **Rate Limit**: Standard API rate limits apply
- **Integration**: Requires Leaflogix POS integration

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the store for which to retrieve tax customer types | Yes |

### Query Parameters

No query parameters are required for this endpoint.

## Response

### Success Response (200 OK)

```json
[
  {
    "id": "1",
    "name": "Recreational",
    "description": "Recreational customer type",
    "isActive": true,
    "isDefault": true
  },
  {
    "id": "2",
    "name": "Medical",
    "description": "Medical customer type",
    "isActive": true,
    "isDefault": false
  }
]
```

The response includes an array of tax customer types, each with the following fields:

| Field | Description | Type |
|-------|-------------|------|
| id | The unique identifier of the customer type in Leaflogix | string |
| name | The name of the customer type (either "Recreational" or "Medical") | string |
| description | A description of the customer type | string |
| isActive | Whether the customer type is active | boolean |
| isDefault | Whether the customer type is the default | boolean |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=123"}` |
| 422 Unprocessable Entity | Store is not configured for Leaflogix | `{"error": "Store is not configured for Leaflogix integration"}` |
| 500 Internal Server Error | Leaflogix API error | `{"error": "Leaflogix API error: Unauthorized"}` |

## Implementation Details

- **Controller**: `StoresController#tax_customer_types`
- **Model**: `Store`
- **Policy**: `StorePolicy#tax_customer_types?`
- **External API**: `Leaflogix::ApiClient#get_customer_types`
- **Database Queries**: 
  - Select query to find the store by ID

### Authorization

The endpoint uses the `StorePolicy#tax_customer_types?` method to determine if the user is authorized to retrieve tax customer types for the store. Only admin users are allowed to access this endpoint:

```ruby
def tax_customer_types?
  admin?
end
```

### Integration with Leaflogix

The endpoint integrates with the Leaflogix POS system to retrieve customer types. The integration process involves the following steps:

1. The controller initializes a Leaflogix API client with the store's API configuration
2. The API client makes a GET request to the Leaflogix API endpoint `/customer/customer-types`
3. The API client handles authentication with Leaflogix using the store's API key
4. The response from Leaflogix is filtered to include only "Recreational" and "Medical" customer types
5. The filtered customer types are returned in the response

### Implementation Code

```ruby
def tax_customer_types
  authorize @store

  api_client = Leaflogix::ApiClient.new(@store.leaflogix_api_config)

  tax_customer_types = api_client.get_customer_types

  # only return the tax customer types that are Recreational or Medical
  tax_customer_types = tax_customer_types.select { |tax_customer_type| tax_customer_type['name'] == 'Recreational' || tax_customer_type['name'] == 'Medical' }

  render json: tax_customer_types, status: :ok
end
```

The `leaflogix_api_config` method in the Store model provides the API configuration for the Leaflogix API client:

```ruby
def leaflogix_api_config
  { api_key: api_key }
end
```

The `get_customer_types` method in the Leaflogix API client makes the API request to Leaflogix:

```ruby
def get_customer_types
  headers = auth_headers.merge(
    'Content-Type' => 'application/json-patch+json',
    'Accept' => 'application/json'
  )

  response = get(customer_types, headers: headers)

  if response.success?
    response.parsed_response
  else
    Rails.logger.error response.body
    reason = response.message
    raise Leaflogix::LeaflogixError, "Leaflogix API error: #{reason}"
  end
end
```

## Examples

### Example Request

```bash
curl -X GET \
  https://api.peakbeyond.com/stores/123e4567-e89b-12d3-a456-426614174000/tax_customer_types \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### Example Response

```json
[
  {
    "id": "1",
    "name": "Recreational",
    "description": "Recreational customer type",
    "isActive": true,
    "isDefault": true
  },
  {
    "id": "2",
    "name": "Medical",
    "description": "Medical customer type",
    "isActive": true,
    "isDefault": false
  }
]
```

## Common Use Cases

1. **Tax Configuration**: Retrieve tax customer types to configure tax rates for different customer types
2. **Store Setup**: Set up a new store with appropriate tax customer types
3. **Integration Verification**: Verify that the Leaflogix integration is working correctly
4. **Tax Reporting**: Use tax customer types for tax reporting and compliance

## Related Endpoints

- [`GET /stores/:id`](get_store_endpoint.md): Get a specific store
- [`PUT /stores/:id`](update_store_endpoint.md): Update a store
- [`POST /stores/:id/generate_token`](generate_store_token_endpoint.md): Generate API token for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The Tax Customer Types endpoint is specific to stores with Leaflogix POS integration. Make sure to document this requirement.
- **StoreManagementAgent**: This endpoint is useful for configuring tax settings for a store. The customer types returned are filtered to include only "Recreational" and "Medical" types.
- **IntegrationSpecialistAgent**: The endpoint relies on the Leaflogix API integration. Ensure that the store has a valid Leaflogix API key configured.
- **TaxConfigurationAgent**: The customer types returned by this endpoint are used for tax configuration. Different tax rates may apply to different customer types.

## Technical Debt and Known Issues

- The endpoint doesn't handle the case where the store is not configured for Leaflogix integration, which could lead to unexpected errors.
- There's no caching of the customer types, which means that each request makes a new API call to Leaflogix.
- The filtering of customer types is done in the controller rather than in the API client, which could be refactored for better separation of concerns.
- The endpoint doesn't provide a way to retrieve all customer types, only the filtered ones.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-13 | Initial documentation | AI Assistant | 