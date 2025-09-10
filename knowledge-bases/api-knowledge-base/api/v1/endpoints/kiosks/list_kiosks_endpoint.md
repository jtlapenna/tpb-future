---
title: List Kiosks
description: API endpoint for retrieving a paginated and filtered list of kiosks
last_updated: 2023-07-15
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/kiosk_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/serializers/kiosk_serializer.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/concerns/paged.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/concerns/sortable.rb
tags:
  - api
  - administrative
  - kiosks
  - listing
  - pagination
  - filtering
  - sorting
ai_agent_relevance:
  - APIDocumentationAgent
  - KioskManagementAgent
  - IntegrationSpecialistAgent
---

# List Kiosks

## Overview

This endpoint allows authorized users to retrieve a paginated, filtered, and sorted list of kiosks in the system. The endpoint supports searching by kiosk name or store name, pagination, and sorting by various attributes. The response includes basic information about each kiosk and its associated store and layout.

## Endpoint Details

- **URL**: `GET /kiosks`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Any authenticated user
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Query Parameters

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| q | Search query to filter kiosks by name or store name | string | null | No |
| page | Page number for pagination | integer | 1 | No |
| per_page | Number of items per page | integer | 25 | No |
| sort_by | Field to sort by (e.g., id, name, created_at) | string | id | No |
| sort_direction | Direction to sort (asc or desc) | string | desc | No |

## Response

### Success Response (200 OK)

```json
{
  "kiosks": [
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
        "id": "123e4567-e89b-12d3-a456-426614174002",
        "name": "Downtown Store"
      },
      "layout": {
        "id": "123e4567-e89b-12d3-a456-426614174001",
        "name": "Default Layout"
      }
    },
    {
      "id": "223e4567-e89b-12d3-a456-426614174000",
      "name": "Product Showcase Kiosk",
      "tag_list": ["showcase", "featured"],
      "sensor_method": "rfid",
      "sensor_threshold": 10,
      "rfid_sorting": "custom",
      "rfid_behavior": "default",
      "location": "center display",
      "product_filter_criteria": "brand",
      "product_filter_value_type": "Brand",
      "product_filter_value_id": "323e4567-e89b-12d3-a456-426614174000",
      "product_layout_id": "423e4567-e89b-12d3-a456-426614174000",
      "store": {
        "id": "123e4567-e89b-12d3-a456-426614174002",
        "name": "Downtown Store"
      },
      "layout": {
        "id": "423e4567-e89b-12d3-a456-426614174000",
        "name": "Brand Showcase Layout"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 112,
    "enable_automate_promotions": false
  }
}
```

The response includes an array of kiosk objects and metadata for pagination:

#### Kiosk Object

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

#### Pagination Metadata

| Field | Description | Type |
|-------|-------------|------|
| current_page | The current page number | integer |
| next_page | The next page number, or null if there is no next page | integer or null |
| prev_page | The previous page number, or null if there is no previous page | integer or null |
| total_pages | The total number of pages | integer |
| total_count | The total number of kiosks matching the query | integer |
| enable_automate_promotions | Whether automatic promotions are enabled | boolean |

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |

## Implementation Details

- **Controller**: `KiosksController#index`
- **Model**: `Kiosk`
- **Policy**: `KioskPolicy#index?` and `KioskPolicy::Scope`
- **Serializer**: `KioskSerializer`
- **Concerns**: `Paged`, `Sortable`
- **Database Queries**: 
  - Select query to retrieve kiosks with filtering, pagination, and sorting
  - Join with stores table for store name filtering
  - Includes for eager loading layout, store, and taggings

### Authorization

The endpoint uses the `KioskPolicy#index?` method to determine if the user is authorized to list kiosks. Any authenticated user is allowed to list kiosks:

```ruby
def index?
  user
end
```

However, the scope of visible kiosks is restricted based on the user's role:

```ruby
class Scope < Scope
  def resolve
    if user.admin?
      scope
    else
      scope.owner(user)
    end
  end
end
```

This means that admin users can see all kiosks, while non-admin users can only see kiosks associated with stores they own.

### Pagination

The endpoint uses the `Paged` concern to handle pagination:

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

The endpoint uses the `Sortable` concern to handle sorting:

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

### Implementation Code

```ruby
def index
  authorize Kiosk

  q = params[:q] != nil ? "%" + params[:q] + "%" : "%";

  kiosks = policy_scope(Kiosk)
           .joins(:store)
           .includes(:layout, :store, :taggings)
           .page(page).per(page_size).order(order_fields)
           .where('kiosks.name ILIKE ? OR stores.name ILIKE ?',q,q)
  render json: kiosks, meta: pagination_dict(kiosks)
end
```

## Examples

### Example Request: Basic Listing

```bash
curl -X GET \
  https://api.peakbeyond.com/kiosks \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### Example Request: Searching and Pagination

```bash
curl -X GET \
  'https://api.peakbeyond.com/kiosks?q=entrance&page=1&per_page=10' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### Example Request: Sorting

```bash
curl -X GET \
  'https://api.peakbeyond.com/kiosks?sort_by=name&sort_direction=asc' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

## Common Use Cases

1. **Kiosk Management**: Retrieve a list of all kiosks for management purposes
2. **Store Dashboard**: Display kiosks associated with a specific store
3. **Kiosk Search**: Find kiosks by name or store name
4. **Kiosk Monitoring**: Monitor the status of all kiosks in the system

## Related Endpoints

- [`POST /kiosks`](create_kiosk_endpoint.md): Create a new kiosk
- [`GET /kiosks/:id`](get_kiosk_endpoint.md): Get a specific kiosk
- [`PUT /kiosks/:id`](update_kiosk_endpoint.md): Update a kiosk
- [`POST /kiosks/:id/clone`](clone_kiosk_endpoint.md): Clone a kiosk

## Notes for AI Agents

- **APIDocumentationAgent**: The List Kiosks endpoint supports pagination, sorting, and filtering. Make sure to document these features comprehensively.
- **KioskManagementAgent**: When listing kiosks, be aware that non-admin users can only see kiosks associated with stores they own.
- **IntegrationSpecialistAgent**: The response includes basic information about each kiosk, but not detailed information like RFID products. For detailed information, use the Get Kiosk endpoint.

## Technical Debt and Known Issues

- The endpoint uses a simple ILIKE query for searching, which may not be efficient for large datasets. Consider implementing a more sophisticated search mechanism like Elasticsearch.
- The endpoint doesn't support filtering by tags or other kiosk attributes, which could be useful for more targeted searches.
- The sorting is limited to a single field. Supporting multi-field sorting could enhance the API's flexibility.
- The search query parameter `q` is applied to both kiosk name and store name, which might return unexpected results. Consider separate parameters for more precise filtering.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-15 | Initial documentation | AI Assistant | 