---
title: Update Store
description: API endpoint for updating an existing store in the system
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
  - update
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
---

# Update Store

## Overview

This endpoint allows users to update an existing store in the system. A store represents a physical cannabis dispensary location that is managed through The Peak Beyond's platform. The update operation allows for modifying store details, POS integration settings, and store configuration.

## Endpoint Details

- **URL**: `PUT /stores/:id`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Any authenticated user can update stores they have access to. Admin users have access to all stores and can update additional fields.
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Content-Type | The format of the request body, typically application/json | Yes |
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the store to update | Yes |

### Request Body

```json
{
  "store": {
    "name": "Updated Green Leaf Dispensary",
    "api_type": "treez",
    "api_client_id": "updated_client_123",
    "api_key": "updated_api_key_123",
    "dispensary_name": "Updated Green Leaf",
    "sync_frequency": 120,
    "sync_frequency_offset": 15,
    "api_version": "v2",
    "api_store_id": "updated_store_123",
    "api_automatch": false,
    "api_autopublish": false,
    "override_on_sync": false,
    "preserve_category": false,
    "featured_mode": "rfid_featured",
    "enabled_share_email_product": false,
    "enabled_share_sms_product": false,
    "enabled_continuous_cart": false,
    "block_simultaneous_nfc": true,
    "notifications_title": "Updated Order Notification",
    "notifications_enabled": false,
    "notifications_intro": "An updated order has been placed",
    "notifications_send_to_customer": false,
    "notifications_recipients": ["updated_admin@example.com"],
    "logo_attributes": {
      "id": "456",
      "url": "https://example.com/updated_logo.png"
    },
    "settings_attributes": {
      "id": "789",
      "printer_location": "Back Office",
      "main_color": "#FF0000",
      "secondary_color": "#00FF00",
      "featured_products_on_top_for_brands_page": false,
      "featured_products_on_top_for_effects_and_uses_page": false,
      "featured_products_on_top_for_products_page": false,
      "default_product_description": "Updated high-quality cannabis product",
      "dispensary_license_number": "LIC-654321",
      "lat": 34.0522,
      "lng": -118.2437,
      "global_ad_enabled": false,
      "show_thc_cbd_values": false,
      "show_alternative_flower_icon": false,
      "t_a_c": "Updated terms and conditions text",
      "disable_tax_message": true,
      "rfid_popup_setting": "custom",
      "enable_request_tax": false,
      "use_master_category": true,
      "printer_mac_address": "55:44:33:22:11:00",
      "enable_toggle_tax": false,
      "default_toggle_customer_type": "medCustomer",
      "enable_automate_promotions": true,
      "background_media_attributes": {
        "id": "101",
        "url": "https://example.com/updated_background.jpg"
      }
    }
  }
}
```

The request body for updating a store is similar to the one for creating a store, with the following differences:

1. You only need to include the fields you want to update
2. When updating nested attributes like `logo_attributes` or `settings_attributes`, you need to include the `id` field to identify the existing record
3. To remove a nested attribute, include the `_destroy: true` field

| Property | Description | Type | Required | Constraints | User Access |
|----------|-------------|------|----------|------------|-------------|
| store.name | The name of the store | string | No | Must be unique within a client | All users |
| store.client_id | The ID of the client that owns the store | integer | No | Must be a valid client ID | Admin only |
| store.api_type | The type of POS integration | string | No | One of: "treez", "headset", "flowhub", "leaflogix", "shopify", "covasoft", "blaze" | Admin only |
| store.api_client_id | The client ID for the POS API | string | No | Required if api_type is specified | Admin only |
| store.api_key | The API key for the POS integration | string | No | Required if api_type is specified | Admin only |
| store.dispensary_name | The name of the dispensary in the POS system | string | No | Required if api_type is "treez" | Admin only |
| store.sync_frequency | How often to sync with the POS system (in minutes) | integer | No | Required if api_type is specified, must be > 0 | Admin only |
| store.sync_frequency_offset | Offset for sync timing (in minutes) | integer | No | Must be >= 0 | Admin only |
| store.api_version | The version of the POS API | string | No | | Admin only |
| store.api_store_id | The store ID in the POS system | string | No | Required for some POS integrations | Admin only |
| store.api_automatch | Whether to automatically match products | boolean | No | | Admin only |
| store.api_autopublish | Whether to automatically publish products | boolean | No | | Admin only |
| store.override_on_sync | Whether to override existing data on sync | boolean | No | | Admin only |
| store.preserve_category | Whether to preserve categories on sync | boolean | No | | Admin only |
| store.featured_mode | How featured products are determined | string | No | One of: "rfid_featured", "manual_featured", "rfid_and_manual_featured" | Admin only |
| store.enabled_share_email_product | Whether to enable product sharing via email | boolean | No | | All users |
| store.enabled_share_sms_product | Whether to enable product sharing via SMS | boolean | No | | All users |
| store.enabled_continuous_cart | Whether to enable continuous cart | boolean | No | | All users |
| store.block_simultaneous_nfc | Whether to block simultaneous NFC reads | boolean | No | | All users |
| store.notifications_title | Title for notifications | string | No | Required if notifications_enabled is true | All users |
| store.notifications_enabled | Whether to enable notifications | boolean | No | | All users |
| store.notifications_intro | Introduction text for notifications | string | No | Required if notifications_enabled is true | All users |
| store.notifications_send_to_customer | Whether to send notifications to customers | boolean | No | | All users |
| store.notifications_recipients | Email addresses to receive notifications | array of strings | No | Required if notifications_enabled is true | All users |
| store.logo_attributes.id | ID of the existing logo | string | No | Required when updating an existing logo | All users |
| store.logo_attributes.url | URL of the logo image | string | No | | All users |
| store.logo_attributes._destroy | Whether to remove the logo | boolean | No | Set to true to remove the logo | All users |
| store.settings_attributes.id | ID of the existing settings | string | No | Required when updating existing settings | All users |
| store.settings_attributes.printer_location | Location of the receipt printer | string | No | | All users |
| store.settings_attributes.main_color | Primary color for the store UI | string | No | Hex color code | All users |
| store.settings_attributes.secondary_color | Secondary color for the store UI | string | No | Hex color code | All users |

## Response

### Success Response (200 OK)

```json
{
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Updated Green Leaf Dispensary",
    "current_sync_id": null,
    "featured_mode": "rfid_featured",
    "enabled_share_email_product": false,
    "block_simultaneous_nfc": true,
    "enabled_share_sms_product": false,
    "enabled_continuous_cart": false,
    "api_type": "treez",
    "api_client_id": "updated_client_123",
    "api_key": "updated_api_key_123",
    "dispensary_name": "Updated Green Leaf",
    "sync_frequency": 120,
    "sync_frequency_offset": 15,
    "api_version": "v2",
    "api_automatch": false,
    "override_on_sync": false,
    "preserve_category": false,
    "api_store_id": "updated_store_123",
    "api_autopublish": false,
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
    "use_master_category": true,
    "use_total_thc": null,
    "enable_automate_promotions": true,
    "authorization_blaze": null,
    "partner_key_blaze": null,
    "inventory_list": null,
    "notifications_title": "Updated Order Notification",
    "notifications_recipients": ["updated_admin@example.com"],
    "notifications_enabled": false,
    "notifications_intro": "An updated order has been placed",
    "notifications_send_to_customer": false,
    "logo": {
      "id": "456",
      "url": "https://example.com/updated_logo.png"
    },
    "client": {
      "id": 123,
      "name": "Green Leaf Inc."
    },
    "settings": {
      "id": "789",
      "printer_location": "Back Office",
      "main_color": "#FF0000",
      "secondary_color": "#00FF00",
      "featured_products_on_top_for_brands_page": false,
      "featured_products_on_top_for_effects_and_uses_page": false,
      "featured_products_on_top_for_products_page": false,
      "default_product_description": "Updated high-quality cannabis product",
      "dispensary_license_number": "LIC-654321",
      "lat": 34.0522,
      "lng": -118.2437,
      "global_ad_enabled": false,
      "show_thc_cbd_values": false,
      "show_alternative_flower_icon": false,
      "t_a_c": "Updated terms and conditions text",
      "disable_tax_message": true,
      "rfid_popup_setting": "custom",
      "enable_request_tax": false,
      "use_master_category": true,
      "printer_mac_address": "55:44:33:22:11:00",
      "enable_toggle_tax": false,
      "default_toggle_customer_type": "medCustomer",
      "enable_automate_promotions": true,
      "background_media": {
        "id": "101",
        "url": "https://example.com/updated_background.jpg"
      }
    },
    "store_taxes": [],
    "store_categories": []
  }
}
```

The response format is the same as for the Create Store endpoint, containing the updated store object with all its attributes and associations.

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 400 Bad Request | Invalid parameters | `{"errors": {"name": ["can't be blank"]}}` |
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=123"}` |
| 422 Unprocessable Entity | Validation failed | `{"errors": {"name": ["has already been taken"]}}` |

## Implementation Details

- **Controller**: `StoresController#update`
- **Model**: `Store`
- **Policy**: `StorePolicy#update?`
- **Serializer**: `StoreSerializer`
- **Database Queries**: 
  - Select query to find the store by ID
  - Validation query to check for duplicate store names (if name is being updated)
  - Update query to update the store record
  - Update query to update the store settings record (if settings are being updated)
  - Update query to update the logo asset record (if logo is being updated)
- **Background Jobs**:
  - If POS integration settings are updated, a background job may be scheduled to sync with the POS system
  - If the API type is changed to "shopify", webhooks may be created or updated

## Examples

### Example Request

```bash
curl -X PUT \
  https://api.peakbeyond.com/stores/123e4567-e89b-12d3-a456-426614174000 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "store": {
      "name": "Updated Green Leaf Dispensary",
      "enabled_share_email_product": false,
      "enabled_share_sms_product": false,
      "notifications_title": "Updated Order Notification",
      "notifications_enabled": false,
      "settings_attributes": {
        "id": "789",
        "main_color": "#FF0000",
        "secondary_color": "#00FF00"
      }
    }
  }'
```

### Example Response

```json
{
  "store": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Updated Green Leaf Dispensary",
    "current_sync_id": null,
    "featured_mode": "manual_featured",
    "enabled_share_email_product": false,
    "block_simultaneous_nfc": false,
    "enabled_share_sms_product": false,
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
    "notifications_title": "Updated Order Notification",
    "notifications_recipients": ["admin@example.com"],
    "notifications_enabled": false,
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
      "main_color": "#FF0000",
      "secondary_color": "#00FF00",
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
      "enable_automate_promotions": false
    },
    "store_taxes": [],
    "store_categories": []
  }
}
```

## Common Use Cases

1. **Update Store Branding**: Change the store name, logo, and UI colors to reflect updated branding.
2. **Update POS Integration**: Modify POS integration settings to connect to a different POS system or update API credentials.
3. **Update Store Settings**: Change store settings such as notification preferences, feature flags, or tax settings.
4. **Update Store Location**: Update the store's geographical coordinates for location-based features.

## Authorization Details

The update endpoint has different authorization rules based on the user's role:

1. **Admin Users**: Can update all store attributes, including sensitive fields like API credentials and client associations.
2. **Regular Users**: Can only update non-sensitive fields like store name, notification preferences, and UI settings.

The `StorePolicy` defines which attributes each user role can update:

```ruby
def permitted_attributes
  attrs = [
    :name,
    :enabled_share_email_product, :enabled_continuous_cart, :enabled_share_sms_product, :block_simultaneous_nfc,
    :notifications_title, :notifications_enabled, :notifications_intro,
    :notifications_send_to_customer,
    { notifications_recipients: [] },
    logo_attributes: %i[id url _destroy],
  ]

  admin_attr = %i[
    client_id
    api_client_id api_key api_type dispensary_name sync_frequency sync_frequency_offset
    api_version api_store_id api_automatch api_autopublish
    override_on_sync preserve_category featured_mode sync_tags location_id
    auth0_client_id auth0_client_secret customer_type_filter checkout_type direct_checkout shop_url password
    grant_type client_cova_id client_cova_secret username password_cova company_id location_id_covasoft use_master_category use_total_thc authorization_blaze enable_automate_promotions
    partner_key_blaze inventory_list
  ]

  (
    user.admin? ? attrs + admin_attr : attrs
  ) + [{ settings_attributes: permitted_settings_attributes }]
end
```

## Related Endpoints

- [`POST /stores`](create_store_endpoint.md): Create a new store
- [`GET /stores`](list_stores_endpoint.md): List all stores
- [`GET /stores/:id`](get_store_endpoint.md): Get a specific store
- [`POST /stores/:id/generate_token`](generate_store_token_endpoint.md): Generate API token for a store
- [`GET /stores/:id/tax_customer_types`](#): Get tax customer types for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The update endpoint has different authorization rules based on the user's role. Make sure to document which fields are accessible to which user roles.
- **StoreManagementAgent**: When updating POS integration settings, be aware that this may trigger a new sync job. Also, changing the API type may require additional configuration.
- **IntegrationSpecialistAgent**: If updating POS integration settings, ensure that the new settings are valid and that the POS system is properly configured to work with The Peak Beyond's platform.

## Technical Debt and Known Issues

- The update endpoint doesn't provide a way to validate POS credentials before saving them, which can lead to failed sync jobs if the credentials are incorrect.
- The permitted attributes logic in the policy is complex and may be difficult to maintain as new attributes are added.
- There's no versioning of store configurations, making it difficult to roll back changes if needed.
- The endpoint doesn't provide a way to update store taxes or store categories directly, requiring separate API calls.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-12 | Initial documentation | AI Assistant | 