---
title: Serializers Overview
description: Comprehensive mapping of serializers used in The Peak Beyond's backend system
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Serializers Overview

## Version Information
- **Category**: API Documentation
- **Type**: Technical Specification
- **Current Version**: 1.0.0
- **Status**: Current
- **Last Updated**: Mar 12, 03:05 PM
- **Last Reviewer**: System
- **Next Review Due**: Apr 12, 2024

## Version History

### Version 1.0.0 - Mar 12, 03:05 PM
- **Author**: System
- **Reviewer**: System
- **Changes**:
  - Initial documentation creation
  - Added serializer specifications
  - Documented data formatting
  - Included response patterns
- **Related Updates**:
  - api_controllers_and_endpoints.md - 1.0.0
  - backend_frontend_integration_summary.md - 1.0.0

## Dependencies
- **Required By**:
  - backend_frontend_integration_summary.md - 1.0.0
- **Depends On**:
  - api_controllers_and_endpoints.md - 1.0.0
  - api_documentation_summary.md - 1.0.0

## Review History
- **Last Review**: Mar 12, 03:05 PM
  - **Reviewer**: System
  - **Outcome**: Approved
  - **Comments**: Initial version approved

## Maintenance Schedule
- **Review Frequency**: Monthly
- **Next Scheduled Review**: Apr 12, 2024
- **Update Window**: First week of each month
- **Quality Assurance**: Technical review and response format testing required

## Overview

The Peak Beyond's backend system uses ActiveModel::Serializers to transform model objects into JSON responses. The system implements a comprehensive set of serializers for each model, often with multiple serializer variants for different contexts (minimal, compact, etc.).

## Serializer Categories

The serializers in the system can be categorized into two main groups:

1. **Admin API Serializers**: Used for the admin/CMS API endpoints
2. **Public API Serializers**: Used for the public API endpoints (API/V1)

## Admin API Serializers

### Store-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| StoreSerializer | Full store representation | name, enabled_*, notifications_*, settings, logo |
| StoreMinimalSerializer | Minimal store representation | id, name |
| StoreSettingSerializer | Store settings | printer_location, main_color, secondary_color, featured_products_* |
| StoreSyncSerializer | Store sync status | id, status, created_at |
| StoreSyncItemSerializer | Store sync item | id, status, message |
| StoreTaxSerializer | Store tax information | id, name, rate |

### Product-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| ProductSerializer | Full product representation | id, name, description, attributes |
| ProductMinimalSerializer | Minimal product representation | id, name |
| ProductVariantSerializer | Product variant details | id, name, description, attributes |
| ProductVariantMinimalSerializer | Minimal product variant | id, name, sku |
| StoreProductSerializer | Store-specific product | id, name, description, price, inventory |
| StoreProductMinimalSerializer | Minimal store product | id, name, price |
| StoreProductWithValuesSerializer | Store product with attribute values | id, name, attribute_values |
| StoreProductPromotionSerializer | Product promotion | id, name, discount_type, discount_value |

### Kiosk-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| KioskSerializer | Full kiosk representation | id, name, store, layouts |
| KioskMinimalSerializer | Minimal kiosk representation | id, name |
| KioskLayoutSerializer | Kiosk layout details | id, name, position, navigation |
| KioskProductSerializer | Kiosk-specific product | id, name, description, price |
| KioskProductMinimalSerializer | Minimal kiosk product | id, name |
| KioskProductCompactSerializer | Compact kiosk product | id, name, price |
| KioskProductLayoutSerializer | Kiosk product layout | id, layout_id |
| RfidProductSerializer | RFID product details | id, rfid, product, kiosk |

### Category-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| CategorySerializer | Category details | id, name |
| StoreCategorySerializer | Store-specific category | id, name, parent_id |
| StoreCategoryMinimalSerializer | Minimal store category | id, name |
| StoreCategoryTaxSerializer | Category tax information | id, tax_id, category_id |

### Layout-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| LayoutPositionSerializer | Layout position | id, name |
| LayoutNavigationSerializer | Layout navigation | id, name, items |
| LayoutNavigationItemSerializer | Navigation item | id, name, url |
| ProductLayoutSerializer | Product layout | id, name, tabs |
| ProductLayoutTabSerializer | Layout tab | id, name, elements |
| ProductLayoutElementSerializer | Layout element | id, name, type |
| ProductLayoutValueSerializer | Layout value | id, name, value |

### Asset-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| AssetSerializer | Asset details | id, url |
| AssetElementSerializer | Asset element | id, asset_id, element_id |
| ImageSerializer | Image details | id, url |
| KioskAssetSerializer | Kiosk-specific asset | id, url, kiosk_id |
| VideoImageBackgroundAssetSerializer | Video/image background | id, url, type |
| WelcomeAssetSerializer | Welcome screen asset | id, url, type |

### User-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| UserSerializer | User details | id, name, email, client_id |
| ClientSerializer | Client details | id, name |

### Miscellaneous Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| ArticleSerializer | Article details | id, title, content |
| StoreArticleSerializer | Store-specific article | id, title, content, store_id |
| AttributeDefSerializer | Attribute definition | id, name, attribute_group_id |
| AttributeGroupSerializer | Attribute group | id, name |
| AttributeValueSerializer | Attribute value | id, value, attribute_def_id |
| BrandSerializer | Brand details | id, name |
| BrandMinimalSerializer | Minimal brand | id, name |
| ReviewSerializer | Product review | id, rating, comment |
| TagSerializer | Tag details | id, name |
| TagInfoSerializer | Tag information | id, name, taggable_id |
| VersionSerializer | Version information | id, item_type, event |

## Public API Serializers (API/V1)

### Store-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::StoreSerializer | Public store representation | id, name, settings |
| Api::V1::StoreSettingSerializer | Public store settings | main_color, secondary_color, featured_products_* |

### Product-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::StoreProductSerializer | Public store product | id, name, description, price, images |
| Api::V1::StoreProductMinimalSerializer | Minimal public product | id, name, price |
| Api::V1::ProductValueSerializer | Product value | id, name, value |
| Api::V1::AttributeValueSerializer | Attribute value | id, name, value |

### Kiosk-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::KioskSerializer | Public kiosk representation | id, name, store |
| Api::V1::KioskLayoutSerializer | Public kiosk layout | id, name, position, navigation |
| Api::V1::KioskProductSerializer | Public kiosk product | id, name, description, price, images, attributes |
| Api::V1::KioskProductMinimalSerializer | Minimal public kiosk product | id, name, price |
| Api::V1::RfidProductSerializer | Public RFID product | id, rfid, product |

### Category-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::CategorySerializer | Public category | id, name |
| Api::V1::StoreCategorySerializer | Public store category | id, name, parent_id |
| Api::V1::StoreCategoryMinimalSerializer | Minimal public store category | id, name |

### Layout-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::LayoutNavigationSerializer | Public layout navigation | id, name, items |
| Api::V1::LayoutNavigationItemSerializer | Public navigation item | id, name, url |
| Api::V1::ProductLayoutTabSerializer | Public layout tab | id, name |
| Api::V1::ProductLayoutValueSerializer | Public layout value | id, name, value |
| Api::V1::ProductLayoutValueContainerSerializer | Value container | id, name, values |

### Asset-Related Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::AssetSerializer | Public asset | id, url |
| Api::V1::AssetElementSerializer | Public asset element | id, asset_id, element_id |
| Api::V1::ImageSerializer | Public image | id, url |
| Api::V1::KioskAssetSerializer | Public kiosk asset | id, url, kiosk_id |
| Api::V1::VideoImageBackgroundAssetSerializer | Public background | id, url, type |
| Api::V1::WelcomeAssetSerializer | Public welcome asset | id, url, type |

### Miscellaneous Serializers

| Serializer | Purpose | Key Attributes |
|------------|---------|----------------|
| Api::V1::StoreArticleSerializer | Public store article | id, title, content, products |
| Api::V1::BrandSerializer | Public brand | id, name, logo |
| Api::V1::BrandMinimalSerializer | Minimal public brand | id, name |
| Api::V1::ReviewSerializer | Public review | id, rating, comment |
| Api::V1::TagSerializer | Public tag | id, name |
| Api::V1::AdBannerSerializer | Ad banner | id, name, image, location |
| Api::V1::AdBannerLocationSerializer | Ad banner location | id, name, description |

## Serializer Patterns

### Minimal Serializers

Many models have a "minimal" serializer variant that includes only essential attributes:

```ruby
class StoreMinimalSerializer < ActiveModel::Serializer
  attributes :id, :name
end
```

These are used for list endpoints and as embedded resources in other serializers.

### Inheritance

Some serializers inherit from others to extend their functionality:

```ruby
class Api::V1::StoreProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price
  # Additional attributes and methods
end
```

### Association Serializers

Serializers often include associations using other serializers:

```ruby
class KioskSerializer < ActiveModel::Serializer
  attributes :id, :name
  
  belongs_to :store, serializer: StoreMinimalSerializer
  has_many :layouts, serializer: KioskLayoutSerializer
end
```

### Context-Specific Serialization

Some serializers adjust their output based on the serialization context:

```ruby
class StoreProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price
  
  def price
    object.price_for(current_user)
  end
end
```

## Serializer Usage in Controllers

Controllers use serializers to render JSON responses:

```ruby
# Direct usage
render json: @store, serializer: StoreSerializer

# Collection usage
render json: @stores, each_serializer: StoreMinimalSerializer

# With pagination metadata
render json: @products, 
       each_serializer: ProductSerializer,
       meta: pagination_metadata(@products)
```

## Next Steps

1. Analyze each serializer in detail to understand:
   - Attributes and methods
   - Associations and nested serializers
   - Custom serialization logic

2. Map serializers to their corresponding models and controllers

3. Document serializer inheritance and composition patterns

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial documentation | 