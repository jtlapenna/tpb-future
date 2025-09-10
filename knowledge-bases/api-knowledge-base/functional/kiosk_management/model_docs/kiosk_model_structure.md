---
title: Kiosk Management Model and Structure
description: Detailed documentation of the kiosk model attributes, relationships, and data structure
last_updated: 2023-08-16
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk_layout.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/kiosk_product.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/rfid_product.rb
tags:
  - model
  - kiosk
  - structure
  - data
ai_agent_relevance:
  - KioskManagementAgent
  - DatabaseSpecialistAgent
---

# Kiosk Management Model and Structure

## Overview

This document provides detailed information about the data models and structure used in the kiosk management system of The Peak Beyond's platform. It covers the attributes, relationships, and database schema for kiosks, layouts, product associations, and RFID integrations.

## Core Models

### Kiosk Model

The Kiosk model represents a physical kiosk device deployed in a retail location.

**Attributes:**

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|------------|
| `id` | integer | Unique identifier | Primary key |
| `name` | string | Display name of the kiosk | Required, unique within store |
| `store_id` | integer | ID of the associated store | Required, foreign key |
| `status` | string | Current status (active, inactive) | Required, default: 'active' |
| `created_at` | datetime | Creation timestamp | Automatically set |
| `updated_at` | datetime | Last update timestamp | Automatically updated |
| `last_heartbeat_at` | datetime | Last communication timestamp | Optional |
| `device_identifier` | string | Unique hardware identifier | Required, unique |
| `version` | string | Software version running on kiosk | Optional |

**Relationships:**

- **Belongs to:**
  - `Store`: Each kiosk belongs to a specific store

- **Has one:**
  - `KioskLayout`: Each kiosk has one layout configuration

- **Has many:**
  - `KioskProducts`: Associations between kiosks and products
  - `RfidProducts`: RFID tag associations for products
  - `KioskSettings`: Configuration settings for the kiosk
  - `KioskLogs`: Activity logs for the kiosk

**Validations:**

- `name`: Must be present and unique within the store
- `store_id`: Must reference a valid store
- `status`: Must be one of: 'active', 'inactive', 'maintenance'
- `device_identifier`: Must be present and globally unique

**Scopes:**

- `active`: Returns only active kiosks
- `inactive`: Returns only inactive kiosks
- `by_store(store_id)`: Returns kiosks for a specific store
- `with_heartbeat_since(time)`: Returns kiosks that have communicated since the specified time

### KioskLayout Model

The KioskLayout model represents the visual configuration and appearance of a kiosk.

**Attributes:**

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|------------|
| `id` | integer | Unique identifier | Primary key |
| `kiosk_id` | integer | ID of the associated kiosk | Required, foreign key |
| `template_id` | integer | ID of the layout template | Required, foreign key |
| `home_layout` | string | Home screen layout style | Required |
| `navigation_style` | string | Navigation UI style | Required |
| `welcome_message` | text | Welcome message displayed on kiosk | Optional |
| `background_color` | string | Background color (hex) | Optional |
| `primary_color` | string | Primary color (hex) | Optional |
| `secondary_color` | string | Secondary color (hex) | Optional |
| `text_color` | string | Text color (hex) | Optional |
| `font_family` | string | Font family name | Optional |
| `created_at` | datetime | Creation timestamp | Automatically set |
| `updated_at` | datetime | Last update timestamp | Automatically updated |

**Relationships:**

- **Belongs to:**
  - `Kiosk`: Each layout belongs to a specific kiosk
  - `Template`: Each layout is based on a template

- **Has many:**
  - `LayoutAssets`: Assets (images, videos) used in the layout
  - `LayoutSections`: Sections of the layout (header, footer, etc.)

**Validations:**

- `kiosk_id`: Must reference a valid kiosk
- `template_id`: Must reference a valid template
- `home_layout`: Must be one of: 'grid', 'list', 'carousel'
- `navigation_style`: Must be one of: 'tabbed', 'sidebar', 'dropdown'
- `background_color`, `primary_color`, `secondary_color`, `text_color`: Must be valid hex colors if present

### KioskProduct Model

The KioskProduct model represents the association between a kiosk and a product.

**Attributes:**

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|------------|
| `id` | integer | Unique identifier | Primary key |
| `kiosk_id` | integer | ID of the associated kiosk | Required, foreign key |
| `product_id` | integer | ID of the associated product | Required, foreign key |
| `position` | integer | Display position/order | Optional |
| `featured` | boolean | Whether product is featured | Default: false |
| `created_at` | datetime | Creation timestamp | Automatically set |
| `updated_at` | datetime | Last update timestamp | Automatically updated |

**Relationships:**

- **Belongs to:**
  - `Kiosk`: Each association belongs to a specific kiosk
  - `Product`: Each association references a specific product

**Validations:**

- `kiosk_id`: Must reference a valid kiosk
- `product_id`: Must reference a valid product
- Uniqueness: A product can only be associated with a kiosk once

**Scopes:**

- `featured`: Returns only featured product associations
- `ordered`: Returns associations ordered by position
- `by_category(category_id)`: Returns associations for products in a specific category

### RfidProduct Model

The RfidProduct model represents the association between an RFID tag and a product for a specific kiosk.

**Attributes:**

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|------------|
| `id` | integer | Unique identifier | Primary key |
| `kiosk_id` | integer | ID of the associated kiosk | Required, foreign key |
| `product_id` | integer | ID of the associated product | Required, foreign key |
| `rfid_tag` | string | RFID tag identifier | Required, unique |
| `created_at` | datetime | Creation timestamp | Automatically set |
| `updated_at` | datetime | Last update timestamp | Automatically updated |

**Relationships:**

- **Belongs to:**
  - `Kiosk`: Each RFID association belongs to a specific kiosk
  - `Product`: Each RFID association references a specific product

**Validations:**

- `kiosk_id`: Must reference a valid kiosk
- `product_id`: Must reference a valid product
- `rfid_tag`: Must be present and unique

## Database Schema

### Kiosks Table

```sql
CREATE TABLE kiosks (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  store_id INTEGER NOT NULL REFERENCES stores(id),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  device_identifier VARCHAR(255) NOT NULL UNIQUE,
  version VARCHAR(50),
  last_heartbeat_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_kiosks_on_store_id ON kiosks(store_id);
CREATE INDEX index_kiosks_on_status ON kiosks(status);
CREATE INDEX index_kiosks_on_device_identifier ON kiosks(device_identifier);
```

### Kiosk Layouts Table

```sql
CREATE TABLE kiosk_layouts (
  id SERIAL PRIMARY KEY,
  kiosk_id INTEGER NOT NULL REFERENCES kiosks(id),
  template_id INTEGER NOT NULL REFERENCES templates(id),
  home_layout VARCHAR(50) NOT NULL,
  navigation_style VARCHAR(50) NOT NULL,
  welcome_message TEXT,
  background_color VARCHAR(7),
  primary_color VARCHAR(7),
  secondary_color VARCHAR(7),
  text_color VARCHAR(7),
  font_family VARCHAR(100),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_kiosk_layouts_on_kiosk_id ON kiosk_layouts(kiosk_id);
CREATE INDEX index_kiosk_layouts_on_template_id ON kiosk_layouts(template_id);
```

### Kiosk Products Table

```sql
CREATE TABLE kiosk_products (
  id SERIAL PRIMARY KEY,
  kiosk_id INTEGER NOT NULL REFERENCES kiosks(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  position INTEGER,
  featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE(kiosk_id, product_id)
);

CREATE INDEX index_kiosk_products_on_kiosk_id ON kiosk_products(kiosk_id);
CREATE INDEX index_kiosk_products_on_product_id ON kiosk_products(product_id);
CREATE INDEX index_kiosk_products_on_featured ON kiosk_products(featured);
```

### RFID Products Table

```sql
CREATE TABLE rfid_products (
  id SERIAL PRIMARY KEY,
  kiosk_id INTEGER NOT NULL REFERENCES kiosks(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  rfid_tag VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_rfid_products_on_kiosk_id ON rfid_products(kiosk_id);
CREATE INDEX index_rfid_products_on_product_id ON rfid_products(product_id);
CREATE INDEX index_rfid_products_on_rfid_tag ON rfid_products(rfid_tag);
```

## Entity Relationship Diagram

```
┌─────────────┐       ┌───────────────┐       ┌───────────┐
│             │       │               │       │           │
│    Store    │───1:N─┤     Kiosk     │───1:1─┤KioskLayout│
│             │       │               │       │           │
└─────────────┘       └───────┬───────┘       └───────────┘
                              │
                              │
                 ┌────────────┴─────────────┐
                 │                          │
                 │                          │
        ┌────────▼─────────┐      ┌─────────▼────────┐
        │                  │      │                  │
        │   KioskProduct   │      │   RfidProduct    │
        │                  │      │                  │
        └────────┬─────────┘      └─────────┬────────┘
                 │                          │
                 │                          │
                 │                          │
        ┌────────▼──────────────────────────▼────────┐
        │                                            │
        │                  Product                   │
        │                                            │
        └────────────────────────────────────────────┘
```

## Data Flow

1. **Kiosk Creation**:
   - A new `Kiosk` record is created with basic information
   - A default `KioskLayout` is created and associated with the kiosk
   - The kiosk is associated with a `Store`

2. **Layout Configuration**:
   - The `KioskLayout` record is updated with visual configuration
   - `LayoutAssets` are associated with the layout

3. **Product Association**:
   - `KioskProduct` records are created to associate products with the kiosk
   - Position and featured status are set for each association

4. **RFID Configuration**:
   - `RfidProduct` records are created to associate RFID tags with products for a kiosk

## Caching Strategy

The kiosk management system implements several caching strategies to optimize performance:

1. **Kiosk Configuration Cache**:
   - Kiosk layouts and settings are cached with a 5-minute expiration
   - Cache is invalidated when the layout or settings are updated

2. **Product Association Cache**:
   - Product associations are cached with a 15-minute expiration
   - Cache is invalidated when products are added, removed, or reordered

3. **RFID Tag Cache**:
   - RFID tag mappings are cached with a 1-hour expiration
   - Cache is invalidated when RFID associations are modified

## Data Validation

The system implements several validation mechanisms to ensure data integrity:

1. **Model-level Validations**:
   - Presence validations for required fields
   - Format validations for specific formats (colors, identifiers)
   - Uniqueness validations to prevent duplicates

2. **Database-level Constraints**:
   - Foreign key constraints to ensure referential integrity
   - Unique constraints to prevent duplicate records
   - Not-null constraints for required fields

3. **Application-level Validations**:
   - Business rule validations in service objects
   - Cross-model validations for complex relationships

## Appendix

### Common Queries

**Get all active kiosks for a store with their layouts:**

```ruby
Kiosk.active.where(store_id: store_id).includes(:kiosk_layout)
```

**Get all products associated with a kiosk, ordered by position:**

```ruby
KioskProduct.where(kiosk_id: kiosk_id).ordered.includes(:product)
```

**Find a product by RFID tag for a specific kiosk:**

```ruby
RfidProduct.where(kiosk_id: kiosk_id, rfid_tag: tag).includes(:product).first
```

**Clone a kiosk with its layout:**

```ruby
new_kiosk = original_kiosk.dup
new_kiosk.name = "#{original_kiosk.name} (Copy)"
new_kiosk.save!

new_layout = original_kiosk.kiosk_layout.dup
new_layout.kiosk_id = new_kiosk.id
new_layout.save!
``` 