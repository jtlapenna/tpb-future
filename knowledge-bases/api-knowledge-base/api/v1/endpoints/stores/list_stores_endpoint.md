---
title: List Stores
description: API endpoint for retrieving a list of stores in the system
last_updated: 2023-07-12
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/stores_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/store.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/store_serializer.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/store_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/concerns/paged.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/concerns/sortable.rb
tags:
  - api
  - administrative
  - stores
  - listing
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
---

# List Stores

## Overview

This endpoint allows users to retrieve a paginated list of stores in the system. A store represents a physical cannabis dispensary location that is managed through The Peak Beyond's platform. The list can be filtered, sorted, and paginated according to the user's requirements.

## Endpoint Details

- **URL**: `GET /stores`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Any authenticated user can list stores they have access to. Admin users have access to all stores.
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Query Parameters

| Parameter | Description | Type | Default | Example |
|-----------|-------------|------|---------|---------|
| q | Search query for filtering stores by name | string | null | `Green Leaf` |
| page | Page number for pagination | integer | 1 | `2` |
| per_page | Number of items per page | integer | 25 | `50` |
| sort_by | Field to sort by | string | `id` | `name` |
| sort_direction | Direction to sort (asc or desc) | string | `desc` | `asc` |

## Response

### Success Response (200 OK)

```json
{
  "stores": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Green Leaf Dispensary",
      "current_sync_id": null,
      "featured_mode": "manual_featured",
      "enabled_share_email_product": true,
      "block_simultaneous_nfc": false,
      "enabled_share_sms_product": true,
      "enabled_continuous_cart": true,
      "api_type": "treez",
      "api_client_id": "client_123",
      "api_key": "api_key_123",
      "dispensary_name": "Green Leaf",
      "sync_frequency": 60,
      "sync_frequency_offset": 0,
      "api_version": "v1",
      "api_automatch": true,
      "override_on_sync": true,
      "preserve_category": true,
      "api_store_id": "store_123",
      "api_autopublish": true,
      "webhook_url": {
        "treez": {
          "single_endpoint": "/stores/123e4567-e89b-12d3-a456-426614174000/webhooks/treez/end_point"
        }
      },
      "notifications_title": "Order Notification",
      "notifications_recipients": ["admin@example.com"],
      "notifications_enabled": true,
      "notifications_intro": "A new order has been placed",
      "notifications_send_to_customer": true,
      "logo": {
        "id": "456",
        "url": "https://example.com/logo.png"
      },
      "client": {
        "id": 123,
        "name": "Green Leaf Inc."
      },
      "settings": {
        "id": "789",
        "printer_location": "Front Desk",
        "main_color": "#00FF00",
        "secondary_color": "#0000FF",
        "featured_products_on_top_for_brands_page": true,
        "featured_products_on_top_for_effects_and_uses_page": true,
        "featured_products_on_top_for_products_page": true,
        "default_product_description": "High-quality cannabis product",
        "dispensary_license_number": "LIC-123456",
        "lat": 37.7749,
        "lng": -122.4194,
        "global_ad_enabled": true,
        "show_thc_cbd_values": true,
        "show_alternative_flower_icon": true,
        "t_a_c": "Terms and conditions text",
        "disable_tax_message": false,
        "rfid_popup_setting": "default",
        "enable_request_tax": true,
        "use_master_category": false,
        "printer_mac_address": "00:11:22:33:44:55",
        "enable_toggle_tax": true,
        "default_toggle_customer_type": "recCustomer",
        "enable_automate_promotions": false,
        "background_media": {
          "id": "101",
          "url": "https://example.com/background.jpg"
        },
        "purchase_limits": []
      },
      "store_taxes": [],
      "store_categories": []
    },
    {
      "id": "223e4567-e89b-12d3-a456-426614174001",
      "name": "Blue Sky Dispensary",
      "current_sync_id": null,
      "featured_mode": "rfid_featured",
      "enabled_share_email_product": false,
      "block_simultaneous_nfc": true,
      "enabled_share_sms_product": false,
      "enabled_continuous_cart": false,
      // ... additional store properties
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 125,
    "enable_automate_promotions": false
  }
}
```

The response includes an array of store objects, each with the same structure as the response from the Get Store endpoint. Additionally, a `meta` object is included with pagination information.

| Meta Property | Description | Type |
|---------------|-------------|------|
| current_page | The current page number | integer |
| next_page | The next page number, or null if there is no next page | integer or null |
| prev_page | The previous page number, or null if there is no previous page | integer or null |
| total_pages | The total number of pages | integer |
| total_count | The total number of stores matching the query | integer |
| enable_automate_promotions | Whether automated promotions are enabled | boolean |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |

## Implementation Details

- **Controller**: `StoresController#index`
- **Model**: `Store`
- **Policy**: `StorePolicy#index?` and `StorePolicy::Scope`
- **Serializer**: `StoreSerializer`
- **Concerns**: `Paged` and `Sortable`
- **Database Queries**: 
  - Select query to retrieve stores with filtering, pagination, and sorting
  - Includes eager loading of associations: `:store_taxes`, `:store_categories`, `:client`, `:logo`, and `settings: %i[background_media purchase_limits]`

### Authorization

The endpoint uses two levels of authorization:

1. **Action Authorization**: `authorize Store` checks if the user is authorized to list stores using the `StorePolicy#index?` method.
2. **Scope Authorization**: `policy_scope(Store)` filters the list of stores based on the user's permissions using the `StorePolicy::Scope` class.

For admin users, all stores are accessible. For regular users, only stores they own or have access to are included in the results.

### Pagination

Pagination is implemented using the Kaminari gem and the `Paged` concern:

```ruby
def page
  params[:page] || 1
end

def page_size
  params[:per_page] || Kaminari.config.default_per_page
end

def pagination_dict(collection, enable_automate_promotions = false)
  {
    current_page: collection.current_page,
    next_page: collection.next_page,
    prev_page: collection.prev_page,
    total_pages: collection.total_pages,
    total_count: collection.total_count,
    enable_automate_promotions: enable_automate_promotions
  }
end
```

### Sorting

Sorting is implemented using the `Sortable` concern:

```ruby
def order_by
  params[:sort_by] || :id
end

def order_direction
  params[:sort_direction] == 'asc' ? :asc : :desc
end

def order_fields
  { order_by.to_sym => order_direction.to_sym }
end
```

### Filtering

The endpoint supports filtering stores by name using a case-insensitive partial match:

```ruby
q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
stores = policy_scope(Store)...where('stores.name ILIKE ?', q)
```

## Examples

### Example Request: Basic Listing

```bash
curl -X GET \
  https://api.peakbeyond.com/stores \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### Example Request: Filtered, Sorted, and Paginated

```bash
curl -X GET \
  'https://api.peakbeyond.com/stores?q=Green&page=2&per_page=10&sort_by=name&sort_direction=asc' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

## Common Use Cases

1. **Store Management Dashboard**: Retrieve a list of stores for display in an administrative dashboard.
2. **Store Selection**: Allow users to select a store from a list for further operations.
3. **Store Search**: Enable users to search for specific stores by name.
4. **Store Monitoring**: Monitor the status of multiple stores in a paginated view.

## Related Endpoints

- [`POST /stores`](create_store_endpoint.md): Create a new store
- [`GET /stores/:id`](get_store_endpoint.md): Get a specific store
- [`PUT /stores/:id`](update_store_endpoint.md): Update a store
- [`POST /stores/:id/generate_token`](generate_store_token_endpoint.md): Generate API token for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The List Stores endpoint supports pagination, sorting, and filtering. Make sure to document these features and their parameters.
- **StoreManagementAgent**: When listing stores, be aware that the results are filtered based on the user's permissions. Admin users see all stores, while regular users only see stores they have access to.
- **IntegrationSpecialistAgent**: When integrating with this endpoint, implement pagination handling to retrieve all stores if needed, as the results are paginated.

## Technical Debt and Known Issues

- The search functionality is limited to store names and doesn't support searching by other attributes.
- The endpoint doesn't support advanced filtering options like filtering by API type or status.
- The sorting is limited to a single field and doesn't support multi-field sorting.
- The `enable_automate_promotions` field in the pagination metadata seems out of place and may be a legacy feature.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-12 | Initial documentation | AI Assistant | 