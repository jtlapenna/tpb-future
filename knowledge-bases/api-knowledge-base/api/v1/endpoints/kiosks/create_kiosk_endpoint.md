---
title: Create Kiosk
description: API endpoint for creating a new kiosk in the system
last_updated: 2023-07-14
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/kiosk_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/kiosk_serializer.rb
tags:
  - api
  - administrative
  - kiosks
  - creation
ai_agent_relevance:
  - APIDocumentationAgent
  - KioskManagementAgent
  - IntegrationSpecialistAgent
---

# Create Kiosk

## Overview

This endpoint allows authorized users to create a new kiosk in the system. A kiosk represents a physical device in a store that customers interact with. When a kiosk is created, it is associated with a store and can be configured with various settings such as sensor method, RFID behavior, and product filtering criteria.

## Endpoint Details

- **URL**: `POST /kiosks`
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
  "kiosk": {
    "name": "Main Entrance Kiosk",
    "store_id": "123e4567-e89b-12d3-a456-426614174000",
    "tag_list": ["entrance", "featured"],
    "sensor_method": "rfid",
    "sensor_threshold": 5,
    "rfid_sorting": "alphabetical",
    "rfid_behavior": "default",
    "location": "main entrance",
    "product_filter_criteria": "all"
  }
}
```

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| name | The name of the kiosk | string | Yes |
| store_id | The ID of the store this kiosk belongs to | string | Yes |
| tag_list | Array of tags to associate with the kiosk | array of strings | No |
| sensor_method | The method used for sensing products (e.g., rfid) | string | No |
| sensor_threshold | The threshold value for the sensor | integer | No |
| rfid_sorting | How RFID products are sorted (alphabetical, custom) | string | No |
| rfid_behavior | The behavior of RFID detection | string | No |
| location | The physical location of the kiosk within the store | string | No |
| product_filter_criteria | How products are filtered for this kiosk (all, custom, brand, category) | string | No |
| product_filter_value_type | The type of value used for filtering products (required if product_filter_criteria is not 'all' or 'custom') | string | No |
| product_filter_value_id | The ID of the value used for filtering products (required if product_filter_criteria is not 'all' or 'custom') | string | No |

## Response

### Success Response (201 Created)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Main Entrance Kiosk",
  "tag_list": ["entrance", "featured"],
  "sensor_method": "rfid",
  "sensor_threshold": 5,
  "rfid_sorting": "alphabetical",
  "rfid_behavior": "default",
  "location": "main entrance",
  "product_filter_criteria": "all",
  "product_filter_value_type": null,
  "product_filter_value_id": null,
  "product_layout_id": "123e4567-e89b-12d3-a456-426614174001",
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Downtown Store"
  },
  "layout": {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "name": "Default Layout"
  }
}
```

The response includes the created kiosk with all its attributes, including:

| Field | Description | Type |
|-------|-------------|------|
| id | The unique identifier of the created kiosk | string |
| name | The name of the kiosk | string |
| tag_list | Array of tags associated with the kiosk | array of strings |
| sensor_method | The method used for sensing products | string |
| sensor_threshold | The threshold value for the sensor | integer |
| rfid_sorting | How RFID products are sorted | string |
| rfid_behavior | The behavior of RFID detection | string |
| location | The physical location of the kiosk within the store | string |
| product_filter_criteria | How products are filtered for this kiosk | string |
| product_filter_value_type | The type of value used for filtering products | string or null |
| product_filter_value_id | The ID of the value used for filtering products | string or null |
| product_layout_id | The ID of the layout associated with the kiosk | string |
| store | Basic information about the store this kiosk belongs to | object |
| layout | Basic information about the layout associated with the kiosk | object |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 422 Unprocessable Entity | Validation errors | `{"errors": {"name": ["can't be blank"], "store_id": ["can't be blank"]}}` |

## Implementation Details

- **Controller**: `KiosksController#create`
- **Model**: `Kiosk`
- **Policy**: `KioskPolicy#create?`
- **Serializer**: `KioskSerializer`
- **Database Queries**: 
  - Insert query to create the kiosk
  - Insert query to create the default layout (via callback)
  - Select queries to retrieve associated data for the response

### Authorization

The endpoint uses the `KioskPolicy#create?` method to determine if the user is authorized to create a kiosk. Any authenticated user is allowed to create a kiosk:

```ruby
def create?
  user
end
```

### Validation

The `Kiosk` model includes several validations to ensure data integrity:

- `name` must be present
- `store_id` must be present and reference a valid store
- `rfid_sorting` must be one of the allowed values (alphabetical, custom)
- `sensor_method` must be one of the allowed values (rfid, etc.)
- `product_filter_criteria` must be one of the allowed values (all, custom, brand, category)
- If `product_filter_criteria` is not 'all' or 'custom', then `product_filter_value_type` and `product_filter_value_id` must be present

### Callbacks

The `Kiosk` model includes several callbacks that are triggered when a kiosk is created:

- `before_create`: Builds a default layout if none exists
- `after_create`: Automatically adds products based on the filter criteria

### Implementation Code

```ruby
def create
  authorize Kiosk

  kiosk = Kiosk.new(permitted_attributes(Kiosk))

  if kiosk.save
    render json: kiosk, status: :created
  else
    errors = kiosk.errors.as_json
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
```

## Examples

### Example Request

```bash
curl -X POST \
  https://api.peakbeyond.com/kiosks \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "kiosk": {
      "name": "Main Entrance Kiosk",
      "store_id": "123e4567-e89b-12d3-a456-426614174000",
      "tag_list": ["entrance", "featured"],
      "sensor_method": "rfid",
      "sensor_threshold": 5,
      "rfid_sorting": "alphabetical",
      "rfid_behavior": "default",
      "location": "main entrance",
      "product_filter_criteria": "all"
    }
  }'
```

### Example Response

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Main Entrance Kiosk",
  "tag_list": ["entrance", "featured"],
  "sensor_method": "rfid",
  "sensor_threshold": 5,
  "rfid_sorting": "alphabetical",
  "rfid_behavior": "default",
  "location": "main entrance",
  "product_filter_criteria": "all",
  "product_filter_value_type": null,
  "product_filter_value_id": null,
  "product_layout_id": "123e4567-e89b-12d3-a456-426614174001",
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Downtown Store"
  },
  "layout": {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "name": "Default Layout"
  }
}
```

## Common Use Cases

1. **New Store Setup**: Create kiosks when setting up a new store
2. **Expansion**: Add new kiosks to an existing store
3. **Replacement**: Create a new kiosk to replace a damaged one
4. **Specialized Kiosks**: Create kiosks with specific product filtering for different areas of the store

## Related Endpoints

- [`GET /kiosks`](list_kiosks_endpoint.md): List all kiosks
- [`GET /kiosks/:id`](get_kiosk_endpoint.md): Get a specific kiosk
- [`PUT /kiosks/:id`](update_kiosk_endpoint.md): Update a kiosk
- [`POST /kiosks/:id/clone`](clone_kiosk_endpoint.md): Clone a kiosk

## Notes for AI Agents

- **APIDocumentationAgent**: The Create Kiosk endpoint is a key part of store setup. Make sure to document the relationship between kiosks and stores.
- **KioskManagementAgent**: When creating a kiosk, be aware that the product_filter_criteria determines how products are automatically added to the kiosk.
- **IntegrationSpecialistAgent**: Kiosks are central to the physical store experience. Ensure proper integration with the store's physical layout and product inventory.

## Technical Debt and Known Issues

- The endpoint doesn't validate if the store exists before attempting to create the kiosk, which could lead to foreign key constraint errors.
- There's no validation for the tag_list, which could lead to inconsistent tagging.
- The automatic product addition based on filter criteria could be slow for stores with large inventories.
- The endpoint doesn't provide a way to specify the initial layout configuration, relying instead on the default layout created by the callback.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-14 | Initial documentation | AI Assistant | 