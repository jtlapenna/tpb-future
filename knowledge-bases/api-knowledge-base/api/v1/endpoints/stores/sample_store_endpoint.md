---
title: Create Store
description: API endpoint for creating a new store in the system
last_updated: 2023-07-10
contributors: [AI Assistant]
related_files:
  - app/controllers/api/v1/admin/stores_controller.rb
  - app/models/store.rb
  - app/services/stores/create_service.rb
  - app/serializers/store_serializer.rb
tags:
  - api
  - administrative
  - stores
  - creation
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
---

# Create Store

## Overview

This endpoint allows administrators to create a new store in the system. A store represents a physical cannabis dispensary location that will be managed through The Peak Beyond's platform. Creating a store is typically the first step in setting up a new dispensary in the system.

## Endpoint Details

- **URL**: `POST /api/v1/admin/stores`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Requires admin privileges
- **Rate Limit**: 100 requests per minute

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, typically application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |
| X-Tenant-ID | The tenant ID for multi-tenant operations | Yes |

### Request Body

```json
{
  "store": {
    "name": "Green Leaf Dispensary",
    "address": {
      "street": "123 Main St",
      "city": "San Francisco",
      "state": "CA",
      "zip": "94105",
      "country": "USA"
    },
    "phone": "415-555-1234",
    "email": "info@greenleaf.com",
    "timezone": "America/Los_Angeles",
    "pos_system": "treez",
    "pos_configuration": {
      "api_key": "treez_api_key_123",
      "store_id": "treez_store_123",
      "endpoint_url": "https://api.treez.io/v1.0/"
    },
    "active": true
  }
}
```

| Property | Description | Type | Required | Constraints |
|----------|-------------|------|----------|------------|
| store.name | The name of the store | string | Yes | 2-100 characters |
| store.address.street | Street address | string | Yes | 2-100 characters |
| store.address.city | City | string | Yes | 2-100 characters |
| store.address.state | State/Province | string | Yes | 2-50 characters |
| store.address.zip | Postal/ZIP code | string | Yes | 2-20 characters |
| store.address.country | Country | string | Yes | 2-50 characters |
| store.phone | Contact phone number | string | Yes | Valid phone format |
| store.email | Contact email address | string | Yes | Valid email format |
| store.timezone | Store's timezone | string | Yes | Valid IANA timezone |
| store.pos_system | POS system type | string | Yes | One of: "treez", "flowhub", "meadow", "cova", "blaze" |
| store.pos_configuration | POS-specific configuration | object | Yes | Varies by POS system |
| store.active | Whether the store is active | boolean | No | Defaults to true |

## Response

### Success Response (201 Created)

```json
{
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "type": "store",
    "attributes": {
      "name": "Green Leaf Dispensary",
      "address": {
        "street": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94105",
        "country": "USA"
      },
      "phone": "415-555-1234",
      "email": "info@greenleaf.com",
      "timezone": "America/Los_Angeles",
      "pos_system": "treez",
      "active": true,
      "created_at": "2023-07-10T15:30:45Z",
      "updated_at": "2023-07-10T15:30:45Z"
    },
    "relationships": {
      "kiosks": {
        "links": {
          "related": "/api/v1/admin/stores/123e4567-e89b-12d3-a456-426614174000/kiosks"
        }
      },
      "products": {
        "links": {
          "related": "/api/v1/admin/stores/123e4567-e89b-12d3-a456-426614174000/products"
        }
      }
    }
  }
}
```

| Property | Description | Type |
|----------|-------------|------|
| data.id | Unique identifier for the store | uuid |
| data.type | Resource type | string |
| data.attributes.name | The name of the store | string |
| data.attributes.address | The store's address | object |
| data.attributes.phone | Contact phone number | string |
| data.attributes.email | Contact email address | string |
| data.attributes.timezone | Store's timezone | string |
| data.attributes.pos_system | POS system type | string |
| data.attributes.active | Whether the store is active | boolean |
| data.attributes.created_at | Creation timestamp | datetime |
| data.attributes.updated_at | Last update timestamp | datetime |
| data.relationships | Related resources | object |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 400 Bad Request | Invalid parameters | `{"error": "Invalid parameters", "details": {"store.name": ["is required"]}}` |
| 401 Unauthorized | Authentication required | `{"error": "Authentication required"}` |
| 403 Forbidden | Insufficient permissions | `{"error": "Insufficient permissions to create store"}` |
| 422 Unprocessable Entity | Validation failed | `{"error": "Validation failed", "details": {"store.name": ["must be unique"]}}` |
| 429 Too Many Requests | Rate limit exceeded | `{"error": "Rate limit exceeded"}` |
| 500 Internal Server Error | Server error | `{"error": "Internal server error"}` |

## Implementation Details

- **Controller**: `Api::V1::Admin::StoresController#create`
- **Service Objects**: `Stores::CreateService`
- **Models**: `Store`, `Address`
- **Policies**: `StorePolicy#create?`
- **Serializers**: `StoreSerializer`
- **Database Queries**: 
  - Validation query to check for duplicate store names
  - Insert query to create the store record
  - Insert query to create the address record
- **Performance Considerations**: 
  - POS configuration is stored encrypted in the database
  - Address is stored as a separate record with a foreign key relationship

## Examples

### Example Request

```bash
curl -X POST \
  https://api.peakbeyond.com/api/v1/admin/stores \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-ID: tenant_123' \
  -d '{
    "store": {
      "name": "Green Leaf Dispensary",
      "address": {
        "street": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94105",
        "country": "USA"
      },
      "phone": "415-555-1234",
      "email": "info@greenleaf.com",
      "timezone": "America/Los_Angeles",
      "pos_system": "treez",
      "pos_configuration": {
        "api_key": "treez_api_key_123",
        "store_id": "treez_store_123",
        "endpoint_url": "https://api.treez.io/v1.0/"
      },
      "active": true
    }
  }'
```

### Example Response

```json
{
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "type": "store",
    "attributes": {
      "name": "Green Leaf Dispensary",
      "address": {
        "street": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94105",
        "country": "USA"
      },
      "phone": "415-555-1234",
      "email": "info@greenleaf.com",
      "timezone": "America/Los_Angeles",
      "pos_system": "treez",
      "active": true,
      "created_at": "2023-07-10T15:30:45Z",
      "updated_at": "2023-07-10T15:30:45Z"
    },
    "relationships": {
      "kiosks": {
        "links": {
          "related": "/api/v1/admin/stores/123e4567-e89b-12d3-a456-426614174000/kiosks"
        }
      },
      "products": {
        "links": {
          "related": "/api/v1/admin/stores/123e4567-e89b-12d3-a456-426614174000/products"
        }
      }
    }
  }
}
```

## Common Use Cases

1. **Initial Store Setup**: When a new dispensary is onboarded to the platform, this endpoint is used to create their store record.
2. **Multi-Location Expansion**: When an existing dispensary opens a new location, this endpoint is used to add the new store.
3. **POS Integration Setup**: This endpoint is used to configure the POS integration for a new store.

## Related Endpoints

- [`GET /api/v1/admin/stores`](#): List all stores
- [`GET /api/v1/admin/stores/{id}`](#): Get a specific store
- [`PUT /api/v1/admin/stores/{id}`](#): Update a store
- [`DELETE /api/v1/admin/stores/{id}`](#): Delete a store
- [`POST /api/v1/admin/stores/{id}/kiosks`](#): Add a kiosk to a store

## Notes for AI Agents

- **APIDocumentationAgent**: This endpoint follows the standard JSON:API format for request and response. The POS configuration varies by POS system type.
- **StoreManagementAgent**: When creating a store, ensure that the POS system type is supported and that the POS configuration is valid for that system.
- **IntegrationSpecialistAgent**: After creating a store, you'll need to verify the POS integration by triggering a test sync using the related POS sync endpoint.

## Technical Debt and Known Issues

- The POS configuration validation is currently limited and should be enhanced to validate against specific POS system requirements.
- There's no automatic verification of the POS credentials during store creation.
- Future improvements will include geocoding of the address for location-based features.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-10 | Initial documentation | AI Assistant | 