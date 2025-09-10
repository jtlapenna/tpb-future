---
title: Get Store
description: API endpoint for retrieving a specific store in the system
last_updated: 2023-07-12
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/stores_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/store.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/store_serializer.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/store_policy.rb
tags:
  - api
  - administrative
  - stores
  - retrieval
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
---

# Get Store

## Overview

This endpoint allows users to retrieve detailed information about a specific store in the system. A store represents a physical cannabis dispensary location that is managed through The Peak Beyond's platform. The endpoint returns comprehensive information about the store, including its configuration, settings, and associated entities.

## Endpoint Details

- **URL**: `GET /stores/:id`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Any authenticated user can view stores they have access to. Admin users have access to all stores.
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the store to retrieve | Yes |

## Response

### Success Response (200 OK)

```json
{
  "store": {
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
    "sync_tags": null,
    "location_id": null,
    "auth0_client_id": null,
    "auth0_client_secret": null,
    "customer_type_filter": null,
    "webhook_url": {
      "treez": {
        "single_endpoint": "/stores/123e4567-e89b-12d3-a456-426614174000/webhooks/treez/end_point"
      }
    },
    "checkout_type": null,
    "direct_checkout": null,
    "shop_url": null,
    "password": null,
    "grant_type": null,
    "client_cova_id": null,
    "client_cova_secret": null,
    "username": null,
    "password_cova": null,
    "company_id": null,
    "location_id_covasoft": null,
    "use_master_category": false,
    "use_total_thc": null,
    "enable_automate_promotions": false,
    "authorization_blaze": null,
    "partner_key_blaze": null,
    "inventory_list": null,
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
    "store_taxes": [
      {
        "id": "201",
        "name": "State Tax",
        "rate": 7.25,
        "enabled": true,
        "customer_type": "recCustomer"
      },
      {
        "id": "202",
        "name": "City Tax",
        "rate": 3.0,
        "enabled": true,
        "customer_type": "recCustomer"
      }
    ],
    "store_categories": [
      {
        "id": "301",
        "name": "Flower",
        "position": 1,
        "enabled": true
      },
      {
        "id": "302",
        "name": "Edibles",
        "position": 2,
        "enabled": true
      }
    ]
  }
}
```

The response includes a detailed store object with all its attributes and associations. For a complete description of each field, refer to the [Create Store](create_store_endpoint.md) and [Update Store](update_store_endpoint.md) endpoint documentation.

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=123"}` |

## Implementation Details

- **Controller**: `StoresController#show`
- **Model**: `Store`
- **Policy**: `StorePolicy#show?`
- **Serializer**: `StoreSerializer`
- **Database Queries**: 
  - Select query to find the store by ID
  - Includes eager loading of associations: `:store_taxes`, `:store_categories`, `:client`, `:logo`, and `settings: %i[background_media purchase_limits]`

### Authorization

The endpoint uses two levels of authorization:

1. **Action Authorization**: `authorize @store` checks if the user is authorized to view the store using the `StorePolicy#show?` method.
2. **Scope Authorization**: `find_store` method uses `policy_scope(Store)` to ensure the user can only access stores they have permission to view.

For admin users, all stores are accessible. For regular users, only stores they own or have access to can be retrieved.

### Implementation Code

The implementation of the Get Store endpoint is straightforward:

```ruby
def show
  authorize @store
  render json: @store, include: store_includes
end

private

def find_store
  @store ||= policy_scope(Store).find(params[:id])
end

def store_includes
  ['logo', 'client', 'settings.background_media', 'settings.purchase_limits', 'store_categories', 'store_taxes']
end
```

The `find_store` method is called via a `before_action` filter:

```ruby
before_action :find_store, only: %i[show update generate_token tax_customer_types get_inventory_types]
```

## Examples

### Example Request

```bash
curl -X GET \
  https://api.peakbeyond.com/stores/123e4567-e89b-12d3-a456-426614174000 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

## Common Use Cases

1. **Store Details View**: Retrieve detailed information about a store for display in an administrative interface.
2. **Store Configuration**: Get the current configuration of a store before making updates.
3. **POS Integration Setup**: Retrieve API integration details for a store to set up POS system integration.
4. **Store Monitoring**: Check the current status and settings of a specific store.

## Related Endpoints

- [`GET /stores`](list_stores_endpoint.md): List all stores
- [`POST /stores`](create_store_endpoint.md): Create a new store
- [`PUT /stores/:id`](update_store_endpoint.md): Update a store
- [`POST /stores/:id/generate_token`](generate_store_token_endpoint.md): Generate API token for a store
- [`GET /stores/:id/tax_customer_types`](tax_customer_types_endpoint.md): Get tax customer types for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The Get Store endpoint returns a comprehensive store object with all its attributes and associations. Make sure to document the structure of the response.
- **StoreManagementAgent**: When retrieving a store, be aware that the results are filtered based on the user's permissions. Admin users can access all stores, while regular users can only access stores they have permission to view.
- **IntegrationSpecialistAgent**: The store object contains important information for POS integration, including API credentials and webhook URLs. Make sure to handle this sensitive information securely.

## Technical Debt and Known Issues

- The endpoint doesn't provide a way to selectively include or exclude associations, which could lead to over-fetching of data.
- Sensitive information like API keys is included in the response, which could be a security concern if not handled properly.
- There's no versioning of store configurations, making it difficult to track changes over time.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-12 | Initial documentation | AI Assistant | 