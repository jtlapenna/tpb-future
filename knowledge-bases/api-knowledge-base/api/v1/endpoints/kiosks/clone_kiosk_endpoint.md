---
title: Clone Kiosk
description: API endpoint for creating a copy of an existing kiosk with its layout and assets
last_updated: 2023-07-16
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/operations/clone_kiosk_operation.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/kiosk_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/kiosk_serializer.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk_layout.rb
tags:
  - api
  - administrative
  - kiosks
  - cloning
  - assets
  - layouts
ai_agent_relevance:
  - APIDocumentationAgent
  - KioskManagementAgent
  - IntegrationSpecialistAgent
  - AssetManagementAgent
---

# Clone Kiosk

## Overview

This endpoint allows administrators to create a copy of an existing kiosk, including its layout and associated assets. The cloned kiosk can be created in the same store as the original or in a different store. The cloning process duplicates the kiosk's layout, welcome assets, navigation items, and kiosk assets, creating new copies of all associated S3 assets with unique identifiers.

## Endpoint Details

- **URL**: `POST /kiosks/:id/clone`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Admin users only
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, must be application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the kiosk to clone | Yes |

### Query Parameters

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| from_store_id | The ID of the store where the cloned kiosk should be created. If not provided, the kiosk will be created in the same store as the original. | string | null | No |
| kiosk_new_name | The name for the cloned kiosk. If not provided, the name will be "Copy of [Original Kiosk Name]". | string | null | No |

## Response

### Success Response (201 Created)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Copy of Main Entrance Kiosk",
  "tag_list": ["entrance", "featured"],
  "sensor_method": "rfid",
  "sensor_threshold": 5,
  "rfid_sorting": "alphabetical",
  "rfid_behavior": "default",
  "location": "main entrance",
  "product_filter_criteria": "custom",
  "product_filter_value_type": null,
  "product_filter_value_id": null,
  "product_layout_id": "223e4567-e89b-12d3-a456-426614174000",
  "store": {
    "id": "323e4567-e89b-12d3-a456-426614174000",
    "name": "Downtown Store"
  },
  "layout": {
    "id": "223e4567-e89b-12d3-a456-426614174000",
    "name": "Default Layout"
  }
}
```

The response includes the newly created kiosk with all its attributes, including:

| Field | Description | Type |
|-------|-------------|------|
| id | The unique identifier of the cloned kiosk | string |
| name | The name of the cloned kiosk | string |
| tag_list | Array of tags associated with the kiosk | array of strings |
| sensor_method | The method used for sensing products | string |
| sensor_threshold | The threshold value for the sensor | integer |
| rfid_sorting | How RFID products are sorted | string |
| rfid_behavior | The behavior of RFID detection | string |
| location | The physical location of the kiosk within the store | string |
| product_filter_criteria | How products are filtered for this kiosk (always set to "custom" for cloned kiosks) | string |
| product_filter_value_type | The type of value used for filtering products (null for cloned kiosks) | string or null |
| product_filter_value_id | The ID of the value used for filtering products (null for cloned kiosks) | string or null |
| product_layout_id | The ID of the layout associated with the kiosk | string |
| store | Basic information about the store this kiosk belongs to | object |
| layout | Basic information about the layout associated with the kiosk | object |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions (non-admin user) | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Kiosk not found | `{"error": "Couldn't find Kiosk with 'id'=123"}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=456"}` |
| 422 Unprocessable Entity | Validation errors | `{"errors": {"name": ["can't be blank"]}}` |

## Implementation Details

- **Controller**: `KiosksController#clone`
- **Operation**: `CloneKioskOperation`
- **Policy**: `KioskPolicy#clone?`
- **Serializer**: `KioskSerializer`
- **Models**: `Kiosk`, `KioskLayout`, `WelcomeAsset`, `LayoutNavigation`, `LayoutNavigationItem`, `KioskAsset`, `Asset`
- **Database Queries**: 
  - Select query to find the kiosk by ID
  - Select query to find the store by ID (if from_store_id is provided)
  - Insert queries to create the cloned kiosk and its associated records
  - AWS S3 operations to copy assets

### Authorization

The endpoint uses the `KioskPolicy#clone?` method to determine if the user is authorized to clone a kiosk. Only admin users are allowed to clone kiosks:

```ruby
def clone?
  admin?
end
```

### Cloning Process

The cloning process is handled by the `CloneKioskOperation` class, which:

1. Copies the base attributes from the source kiosk
2. Sets the product filter criteria to "custom" and clears filter values
3. Creates a new layout by duplicating the source kiosk's layout
4. Duplicates the welcome asset if present
5. Duplicates navigation items if present
6. Duplicates kiosk assets if present
7. For each asset, creates a copy in S3 with a unique identifier

```ruby
def call(source_kiosk, source_store, kiosk_new_name = nil)
  kiosk_n = yield copy_base_attributes(source_kiosk, source_store, kiosk_new_name)
  kiosk_n.layout = yield copy_layout(source_kiosk)
  kiosk_n.save ? Success(kiosk_n) : Failure(kiosk_n.errors)
end
```

### Asset Duplication

The operation duplicates all assets associated with the kiosk by:

1. Generating a new key for the asset in S3
2. Copying the asset to the new key
3. Creating a new Asset record with the new URL

```ruby
def clone_url(prev_asset)
  new_key = generate_new_key(prev_asset.url)
  s3 = Aws::S3::Resource.new(region: bucket_region)
  key = key_from_url(prev_asset.url)
  new_object = s3.bucket(bucket_name).object(new_key)
  new_object.copy_from(bucket: bucket_name, key: key, acl: 'public-read')
  new_asset = prev_asset.dup
  new_asset.url = new_object.public_url
  new_asset
end
```

### Implementation Code

```ruby
def clone
  authorize @kiosk

  kiosk_new_name = params[:kiosk_new_name] != nil ? params[:kiosk_new_name] : nil;    
  result = CloneKioskOperation.new.call(@kiosk, @store, kiosk_new_name)

  if result.success?
    render json: result.value!, status: :created
  else
    errors = result.value!.as_json
    render json: { errors: errors }, status: :unprocessable_entity
  end
end

def find_kiosk
  @kiosk ||= policy_scope(Kiosk).find(params[:id])
end

def find_store
  if( params[:from_store_id] != nil ) then
    @store ||= policy_scope(Store).find(params[:from_store_id])
  else
    @store = nil
  end
end
```

## Examples

### Example Request: Clone Kiosk to Same Store

```bash
curl -X POST \
  https://api.peakbeyond.com/kiosks/123e4567-e89b-12d3-a456-426614174000/clone \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "kiosk_new_name": "Entrance Kiosk - Copy"
  }'
```

### Example Request: Clone Kiosk to Different Store

```bash
curl -X POST \
  https://api.peakbeyond.com/kiosks/123e4567-e89b-12d3-a456-426614174000/clone?from_store_id=456e4567-e89b-12d3-a456-426614174000 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

## Common Use Cases

1. **Store Expansion**: Clone kiosks when opening a new store location to replicate successful kiosk configurations
2. **A/B Testing**: Create a copy of a kiosk to test different configurations while keeping the original intact
3. **Template Creation**: Use a well-configured kiosk as a template for creating new kiosks
4. **Backup**: Create a backup copy of a kiosk before making significant changes
5. **Cross-Store Standardization**: Replicate a kiosk configuration across multiple stores for brand consistency

## Related Endpoints

- [`GET /kiosks`](list_kiosks_endpoint.md): List all kiosks
- [`POST /kiosks`](create_kiosk_endpoint.md): Create a new kiosk
- [`GET /kiosks/:id`](get_kiosk_endpoint.md): Get a specific kiosk
- [`PUT /kiosks/:id`](update_kiosk_endpoint.md): Update a kiosk

## Notes for AI Agents

- **APIDocumentationAgent**: The Clone Kiosk endpoint is restricted to admin users only, unlike other kiosk endpoints that are available to all authenticated users.
- **KioskManagementAgent**: When cloning a kiosk, note that the product filter criteria is always set to "custom" and filter values are cleared, regardless of the original kiosk's settings.
- **IntegrationSpecialistAgent**: The cloned kiosk does not include any RFID products or kiosk products from the original kiosk. These need to be configured separately after cloning.
- **AssetManagementAgent**: All assets associated with the kiosk (welcome assets, navigation items, kiosk assets) are duplicated in S3 with unique identifiers to prevent conflicts.

## Technical Debt and Known Issues

- The cloning process does not copy RFID products or kiosk products, which may require additional manual configuration after cloning.
- The operation uses direct AWS S3 API calls rather than a more abstracted storage service, which could make it difficult to change storage providers in the future.
- Error handling for S3 operations is minimal, which could lead to partial cloning if S3 operations fail.
- The operation doesn't handle concurrent cloning of the same kiosk, which could lead to race conditions.
- The endpoint doesn't provide a way to selectively clone certain aspects of a kiosk (e.g., clone layout but not assets).

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-16 | Initial documentation | AI Assistant | 