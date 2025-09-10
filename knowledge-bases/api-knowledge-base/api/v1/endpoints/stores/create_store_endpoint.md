---
title: Create Store
description: API endpoint for creating a new store in the system
last_updated: 2023-07-11
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

- **URL**: `POST /stores`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Requires admin privileges
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, typically application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Request Body

```json
{
  "store": {
    "name": "Green Leaf Dispensary",
    "client_id": 123,
    "api_type": "treez",
    "api_client_id": "client_123",
    "api_key": "api_key_123",
    "dispensary_name": "Green Leaf",
    "sync_frequency": 60,
    "sync_frequency_offset": 0,
    "api_version": "v1",
    "api_store_id": "store_123",
    "api_automatch": true,
    "api_autopublish": true,
    "override_on_sync": true,
    "preserve_category": true,
    "featured_mode": "manual_featured",
    "enabled_share_email_product": true,
    "enabled_share_sms_product": true,
    "enabled_continuous_cart": true,
    "block_simultaneous_nfc": false,
    "notifications_title": "Order Notification",
    "notifications_enabled": true,
    "notifications_intro": "A new order has been placed",
    "notifications_send_to_customer": true,
    "notifications_recipients": ["admin@example.com"],
    "logo_attributes": {
      "url": "https://example.com/logo.png"
    },
    "settings_attributes": {
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
      "background_media_attributes": {
        "url": "https://example.com/background.jpg"
      }
    }
  }
}
```

| Property | Description | Type | Required | Constraints |
|----------|-------------|------|----------|------------|
| store.name | The name of the store | string | Yes | Must be unique within a client |
| store.client_id | The ID of the client that owns the store | integer | No | Must be a valid client ID |
| store.api_type | The type of POS integration | string | No | One of: "treez", "headset", "flowhub", "leaflogix", "shopify", "covasoft", "blaze" |
| store.api_client_id | The client ID for the POS API | string | No | Required if api_type is specified |
| store.api_key | The API key for the POS integration | string | No | Required if api_type is specified |
| store.dispensary_name | The name of the dispensary in the POS system | string | No | Required if api_type is "treez" |
| store.sync_frequency | How often to sync with the POS system (in minutes) | integer | No | Required if api_type is specified, must be > 0 |
| store.sync_frequency_offset | Offset for sync timing (in minutes) | integer | No | Must be >= 0 |
| store.api_version | The version of the POS API | string | No | |
| store.api_store_id | The store ID in the POS system | string | No | Required for some POS integrations |
| store.api_automatch | Whether to automatically match products | boolean | No | |
| store.api_autopublish | Whether to automatically publish products | boolean | No | |
| store.override_on_sync | Whether to override existing data on sync | boolean | No | |
| store.preserve_category | Whether to preserve categories on sync | boolean | No | |
| store.featured_mode | How featured products are determined | string | No | One of: "rfid_featured", "manual_featured", "rfid_and_manual_featured" |
| store.enabled_share_email_product | Whether to enable product sharing via email | boolean | No | |
| store.enabled_share_sms_product | Whether to enable product sharing via SMS | boolean | No | |
| store.enabled_continuous_cart | Whether to enable continuous cart | boolean | No | |
| store.block_simultaneous_nfc | Whether to block simultaneous NFC reads | boolean | No | |
| store.notifications_title | Title for notifications | string | No | Required if notifications_enabled is true |
| store.notifications_enabled | Whether to enable notifications | boolean | No | |
| store.notifications_intro | Introduction text for notifications | string | No | Required if notifications_enabled is true |
| store.notifications_send_to_customer | Whether to send notifications to customers | boolean | No | |
| store.notifications_recipients | Email addresses to receive notifications | array of strings | No | Required if notifications_enabled is true |
| store.logo_attributes | Attributes for the store logo | object | No | |
| store.logo_attributes.url | URL of the logo image | string | No | |
| store.settings_attributes | Attributes for store settings | object | No | |
| store.settings_attributes.printer_location | Location of the receipt printer | string | No | |
| store.settings_attributes.main_color | Primary color for the store UI | string | No | Hex color code |
| store.settings_attributes.secondary_color | Secondary color for the store UI | string | No | Hex color code |

## Response

### Success Response (201 Created)

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
      }
    },
    "store_taxes": [],
    "store_categories": []
  }
}
```

| Property | Description | Type |
|----------|-------------|------|
| store.id | Unique identifier for the store | uuid |
| store.name | The name of the store | string |
| store.current_sync_id | ID of the current sync operation, if any | uuid or null |
| store.featured_mode | How featured products are determined | string |
| store.enabled_share_email_product | Whether product sharing via email is enabled | boolean |
| store.block_simultaneous_nfc | Whether simultaneous NFC reads are blocked | boolean |
| store.enabled_share_sms_product | Whether product sharing via SMS is enabled | boolean |
| store.enabled_continuous_cart | Whether continuous cart is enabled | boolean |
| store.api_type | The type of POS integration | string |
| store.api_client_id | The client ID for the POS API | string |
| store.api_key | The API key for the POS integration | string |
| store.dispensary_name | The name of the dispensary in the POS system | string |
| store.sync_frequency | How often to sync with the POS system (in minutes) | integer |
| store.sync_frequency_offset | Offset for sync timing (in minutes) | integer |
| store.api_version | The version of the POS API | string |
| store.api_automatch | Whether automatic product matching is enabled | boolean |
| store.override_on_sync | Whether existing data is overridden on sync | boolean |
| store.preserve_category | Whether categories are preserved on sync | boolean |
| store.api_store_id | The store ID in the POS system | string |
| store.api_autopublish | Whether automatic product publishing is enabled | boolean |
| store.webhook_url | URLs for webhook endpoints | object |
| store.notifications_title | Title for notifications | string |
| store.notifications_recipients | Email addresses to receive notifications | array of strings |
| store.notifications_enabled | Whether notifications are enabled | boolean |
| store.notifications_intro | Introduction text for notifications | string |
| store.notifications_send_to_customer | Whether notifications are sent to customers | boolean |
| store.logo | The store's logo | object |
| store.client | The client that owns the store | object |
| store.settings | The store's settings | object |
| store.store_taxes | The store's tax configurations | array |
| store.store_categories | The store's product categories | array |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 400 Bad Request | Invalid parameters | `{"errors": {"name": ["can't be blank"]}}` |
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 422 Unprocessable Entity | Validation failed | `{"errors": {"name": ["has already been taken"]}}` |

## Implementation Details

- **Controller**: `StoresController#create`
- **Model**: `Store`
- **Policy**: `StorePolicy#create?`
- **Serializer**: `StoreSerializer`
- **Database Queries**: 
  - Validation query to check for duplicate store names
  - Insert query to create the store record
  - Insert query to create the store settings record
  - Insert query to create the logo asset record (if provided)
- **Background Jobs**:
  - A background job is scheduled to sync with the POS system if API credentials are provided
  - Webhooks are created for Shopify integration if the API type is "shopify"

## Examples

### Example Request

```bash
curl -X POST \
  https://api.peakbeyond.com/stores \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "store": {
      "name": "Green Leaf Dispensary",
      "client_id": 123,
      "api_type": "treez",
      "api_client_id": "client_123",
      "api_key": "api_key_123",
      "dispensary_name": "Green Leaf",
      "sync_frequency": 60,
      "sync_frequency_offset": 0,
      "api_version": "v1",
      "api_store_id": "store_123",
      "api_automatch": true,
      "api_autopublish": true,
      "override_on_sync": true,
      "preserve_category": true,
      "featured_mode": "manual_featured",
      "enabled_share_email_product": true,
      "enabled_share_sms_product": true,
      "enabled_continuous_cart": true,
      "block_simultaneous_nfc": false,
      "notifications_title": "Order Notification",
      "notifications_enabled": true,
      "notifications_intro": "A new order has been placed",
      "notifications_send_to_customer": true,
      "notifications_recipients": ["admin@example.com"],
      "logo_attributes": {
        "url": "https://example.com/logo.png"
      },
      "settings_attributes": {
        "printer_location": "Front Desk",
        "main_color": "#00FF00",
        "secondary_color": "#0000FF"
      }
    }
  }'
```

### Example Response

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
      "secondary_color": "#0000FF"
    },
    "store_taxes": [],
    "store_categories": []
  }
}
```

## Common Use Cases

1. **Initial Store Setup**: When a new dispensary is onboarded to the platform, this endpoint is used to create their store record.
2. **Multi-Location Expansion**: When an existing dispensary opens a new location, this endpoint is used to add the new store.
3. **POS Integration Setup**: This endpoint is used to configure the POS integration for a new store.

## Related Endpoints

- [`GET /stores`](#): List all stores
- [`GET /stores/:id`](#): Get a specific store
- [`PUT /stores/:id`](#): Update a store
- [`POST /stores/:id/generate_token`](#): Generate API token for a store
- [`GET /stores/:id/tax_customer_types`](#): Get tax customer types for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The store creation endpoint is a fundamental part of the system setup. Note that different POS integrations require different configuration parameters.
- **StoreManagementAgent**: When creating a store, ensure that the POS system type is supported and that the required configuration parameters for that POS system are provided.
- **IntegrationSpecialistAgent**: After creating a store with POS integration, verify that the sync job is scheduled and that the webhook URL is properly configured.

## Technical Debt and Known Issues

- The validation for POS-specific configuration parameters is implemented in the model, which can make it difficult to understand what parameters are required for each POS type.
- There's no automatic verification of the POS credentials during store creation, which can lead to failed sync jobs if the credentials are incorrect.
- The store creation process schedules background jobs for syncing with the POS system, but there's no feedback mechanism to notify administrators if these jobs fail.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-11 | Initial documentation | AI Assistant | 