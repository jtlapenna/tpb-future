---
title: Update Kiosk
description: API endpoint for updating an existing kiosk in the system
last_updated: 2023-07-14
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/kiosk_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/kiosk_serializer.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/rfid_product.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/brand_and_store_category.rb
tags:
  - api
  - administrative
  - kiosks
  - update
  - rfid
ai_agent_relevance:
  - APIDocumentationAgent
  - KioskManagementAgent
  - IntegrationSpecialistAgent
  - RFIDConfigurationAgent
---

# Update Kiosk

## Overview

This endpoint allows authorized users to update an existing kiosk in the system. The update can include changes to basic kiosk properties as well as complex operations on associated RFID products. The endpoint handles the creation, update, and deletion of BrandAndStoreCategory associations when RFID products are updated.

## Endpoint Details

- **URL**: `PUT /kiosks/:id`
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

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the kiosk to update | Yes |

### Request Body

```json
{
  "kiosk": {
    "name": "Updated Kiosk Name",
    "tag_list": ["entrance", "featured", "new-tag"],
    "sensor_method": "rfid",
    "sensor_threshold": 10,
    "rfid_sorting": "alphabetical",
    "rfid_behavior": "default",
    "location": "main entrance",
    "product_filter_criteria": "brand",
    "product_filter_value_type": "Brand",
    "product_filter_value_id": "123e4567-e89b-12d3-a456-426614174001",
    "rfid_products_attributes": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174002",
        "rfid": "0123456789",
        "rfid_entity_type": "KioskProduct",
        "rfid_entity_id": "123e4567-e89b-12d3-a456-426614174003",
        "order": 1
      },
      {
        "rfid": "9876543210",
        "rfid_entity_type": "BrandAndStoreCategory",
        "rfid_entity_id": "123e4567-e89b-12d3-a456-426614174004",
        "rfid_sub_entity_id": "123e4567-e89b-12d3-a456-426614174005",
        "order": 2
      },
      {
        "id": "123e4567-e89b-12d3-a456-426614174006",
        "_destroy": true
      }
    ]
  }
}
```

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| name | The updated name of the kiosk | string | No |
| tag_list | Array of tags to associate with the kiosk | array of strings | No |
| sensor_method | The method used for sensing products (e.g., rfid) | string | No |
| sensor_threshold | The threshold value for the sensor | integer | No |
| rfid_sorting | How RFID products are sorted (alphabetical, custom) | string | No |
| rfid_behavior | The behavior of RFID detection | string | No |
| location | The physical location of the kiosk within the store | string | No |
| product_filter_criteria | How products are filtered for this kiosk (all, custom, brand, category) | string | No |
| product_filter_value_type | The type of value used for filtering products | string | No |
| product_filter_value_id | The ID of the value used for filtering products | string | No |
| rfid_products_attributes | Array of RFID products to create, update, or delete | array of objects | No |

#### RFID Products Attributes

| Property | Description | Type | Required |
|----------|-------------|------|----------|
| id | The ID of the existing RFID product (required for updates or deletions) | string | No |
| rfid | The RFID tag value | string | No |
| rfid_entity_type | The type of entity associated with the RFID (KioskProduct, BrandAndStoreCategory) | string | No |
| rfid_entity_id | The ID of the entity associated with the RFID | string | No |
| rfid_sub_entity_id | The ID of the sub-entity (required for BrandAndStoreCategory) | string | No |
| order | The display order of the RFID product | integer | No |
| _destroy | Set to true to delete the RFID product | boolean | No |

## Response

### Success Response (200 OK)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Updated Kiosk Name",
  "tag_list": ["entrance", "featured", "new-tag"],
  "sensor_method": "rfid",
  "sensor_threshold": 10,
  "rfid_sorting": "alphabetical",
  "rfid_behavior": "default",
  "location": "main entrance",
  "product_filter_criteria": "brand",
  "product_filter_value_type": "Brand",
  "product_filter_value_id": "123e4567-e89b-12d3-a456-426614174001",
  "product_layout_id": "123e4567-e89b-12d3-a456-426614174007",
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174008",
    "name": "Downtown Store"
  },
  "layout": {
    "id": "123e4567-e89b-12d3-a456-426614174007",
    "name": "Default Layout"
  }
}
```

The response includes the updated kiosk with all its attributes, including:

| Field | Description | Type |
|-------|-------------|------|
| id | The unique identifier of the kiosk | string |
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
| 404 Not Found | Kiosk not found | `{"error": "Couldn't find Kiosk with 'id'=123"}` |
| 422 Unprocessable Entity | Validation errors | `{"errors": {"name": ["can't be blank"]}}` |
| 422 Unprocessable Entity | BrandAndStoreCategory validation errors | `{"errors": "BrandAndStoreCategory must have brand_id and store_category_id"}` |

## Implementation Details

- **Controller**: `KiosksController#update`
- **Model**: `Kiosk`, `RfidProduct`, `BrandAndStoreCategory`
- **Policy**: `KioskPolicy#update?`
- **Serializer**: `KioskSerializer`
- **Database Queries**: 
  - Select query to find the kiosk by ID
  - Update query to update the kiosk
  - Insert, update, and delete queries for RFID products and BrandAndStoreCategory associations
  - Select queries to retrieve associated data for the response

### Authorization

The endpoint uses the `KioskPolicy#update?` method to determine if the user is authorized to update a kiosk. Any authenticated user is allowed to update a kiosk:

```ruby
def update?
  user
end
```

### RFID Products Handling

The update method includes complex logic for handling RFID products, particularly those of type `BrandAndStoreCategory`:

1. For new `BrandAndStoreCategory` RFID products (no ID provided):
   - A new `BrandAndStoreCategory` record is created with the provided brand_id, store_category_id, and kiosk_id
   - The rfid_entity_id is updated to reference the new `BrandAndStoreCategory` record

2. For existing `BrandAndStoreCategory` RFID products (ID provided):
   - The existing `RfidProduct` is found
   - The associated `BrandAndStoreCategory` record is updated with the provided brand_id and store_category_id

3. For `BrandAndStoreCategory` RFID products marked for deletion (_destroy = true):
   - The associated `BrandAndStoreCategory` record is queued for deletion
   - After the kiosk is updated, the queued `BrandAndStoreCategory` records are deleted

4. For `KioskProduct` RFID products:
   - The associated `KioskProduct` and `StoreProduct` records are touched to update their timestamps

### Implementation Code

```ruby
def update
  authorize @kiosk

  Rails.logger.info("Updating Kiosk and maybe rfids")
  Rails.logger.info(params.inspect)
  brand_and_store_category_to_deletes = []

  for rfid_updated in (params["kiosk"]["rfid_products_attributes"] || [])
    if rfid_updated["rfid_entity_type"] == "BrandAndStoreCategory"
      if rfid_updated["rfid_entity_id"] && rfid_updated["rfid_sub_entity_id"]
        if !rfid_updated["_destroy"]
          if rfid_updated["id"].nil?
            # Create new BrandAndStoreCategory
            brand_and_store_category = BrandAndStoreCategory.create(brand_id: rfid_updated["rfid_entity_id"], store_category_id: rfid_updated["rfid_sub_entity_id"], kiosk_id: @kiosk.id)

            if brand_and_store_category.errors.any?
              render json: { errors: brand_and_store_category.errors.as_json }
              return
            else
              rfid_updated["rfid_entity_id"] = brand_and_store_category.id
            end
          else
            # Update BrandAndStoreCategory
            rfid_product = RfidProduct.find(rfid_updated["id"])
            brand_and_store_category = BrandAndStoreCategory.find(rfid_product.rfid_entity_id)
            brand_and_store_category.update(brand_id: rfid_updated["rfid_entity_id"], store_category_id: rfid_updated["rfid_sub_entity_id"], kiosk_id: @kiosk.id)

            rfid_updated["rfid_entity_id"] = rfid_product.rfid_entity_id
          end
        else
          # Delete BrandAndStoreCategory
          rfid_product = RfidProduct.find(rfid_updated["id"])
          brand_and_store_category = BrandAndStoreCategory.find_by(id: rfid_product.rfid_entity_id)
          brand_and_store_category_to_deletes.push(brand_and_store_category) if brand_and_store_category
        end
      else
        render json: { errors: "BrandAndStoreCategory must have brand_id and store_category_id" }
        return
      end
    end
  end

  if @kiosk.update(permitted_attributes(@kiosk))
    for rfid_updated in (params["kiosk"]["rfid_products_attributes"] || []) do
      if (rfid_updated["rfid_entity_type"] == "KioskProduct") && rfid_updated["rfid_entity_id"]
        kiosk_product = KioskProduct.find(rfid_updated["rfid_entity_id"])
        kiosk_product.touch
        StoreProduct.find(kiosk_product.store_product_id).touch
      end
    end

    # Delete BrandAndStoreCategory
    brand_and_store_category_to_deletes.each do |brand_and_store_category_to_delete|
      brand_and_store_category_to_delete.destroy
    end
    render json: @kiosk
  else
    errors = @kiosk.errors.as_json
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
```

## Examples

### Example Request: Update Basic Kiosk Properties

```bash
curl -X PUT \
  https://api.peakbeyond.com/kiosks/123e4567-e89b-12d3-a456-426614174000 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "kiosk": {
      "name": "Updated Kiosk Name",
      "location": "main entrance",
      "sensor_threshold": 10
    }
  }'
```

### Example Request: Update RFID Products

```bash
curl -X PUT \
  https://api.peakbeyond.com/kiosks/123e4567-e89b-12d3-a456-426614174000 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -d '{
    "kiosk": {
      "rfid_products_attributes": [
        {
          "rfid": "0123456789",
          "rfid_entity_type": "KioskProduct",
          "rfid_entity_id": "123e4567-e89b-12d3-a456-426614174003",
          "order": 1
        },
        {
          "id": "123e4567-e89b-12d3-a456-426614174006",
          "_destroy": true
        }
      ]
    }
  }'
```

### Example Response

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Updated Kiosk Name",
  "tag_list": ["entrance", "featured"],
  "sensor_method": "rfid",
  "sensor_threshold": 10,
  "rfid_sorting": "alphabetical",
  "rfid_behavior": "default",
  "location": "main entrance",
  "product_filter_criteria": "all",
  "product_filter_value_type": null,
  "product_filter_value_id": null,
  "product_layout_id": "123e4567-e89b-12d3-a456-426614174007",
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174008",
    "name": "Downtown Store"
  },
  "layout": {
    "id": "123e4567-e89b-12d3-a456-426614174007",
    "name": "Default Layout"
  }
}
```

## Common Use Cases

1. **Kiosk Reconfiguration**: Update a kiosk's configuration to change its behavior or appearance
2. **RFID Management**: Add, update, or remove RFID products associated with a kiosk
3. **Product Filtering**: Change how products are filtered for a kiosk
4. **Location Change**: Update a kiosk's location within a store
5. **Tagging**: Add or remove tags to categorize kiosks

## Related Endpoints

- [`GET /kiosks`](list_kiosks_endpoint.md): List all kiosks
- [`POST /kiosks`](create_kiosk_endpoint.md): Create a new kiosk
- [`GET /kiosks/:id`](get_kiosk_endpoint.md): Get a specific kiosk
- [`POST /kiosks/:id/clone`](clone_kiosk_endpoint.md): Clone a kiosk

## Notes for AI Agents

- **APIDocumentationAgent**: The Update Kiosk endpoint has complex logic for handling RFID products, particularly those of type BrandAndStoreCategory. Make sure to document this complexity.
- **KioskManagementAgent**: When updating a kiosk, be aware that changing the product_filter_criteria may trigger automatic product additions or removals, which could affect the kiosk's inventory.
- **IntegrationSpecialistAgent**: The update process includes touching associated KioskProduct and StoreProduct records, which updates their timestamps. This may trigger cache invalidation or other time-based behaviors.
- **RFIDConfigurationAgent**: The endpoint supports complex RFID product management, including creating, updating, and deleting BrandAndStoreCategory associations. Ensure proper handling of these operations.

## Technical Debt and Known Issues

- The endpoint has complex logic for handling RFID products, which could be refactored into a separate service object for better maintainability.
- The error handling for BrandAndStoreCategory validation could be improved to provide more detailed error messages.
- The endpoint doesn't validate if the referenced entities (KioskProduct, StoreProduct, etc.) exist before attempting to update them, which could lead to errors.
- The endpoint doesn't handle concurrent updates, which could lead to race conditions if multiple users update the same kiosk simultaneously.
- The endpoint doesn't provide a way to update the kiosk's layout directly, requiring a separate API call.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-14 | Initial documentation | AI Assistant | 