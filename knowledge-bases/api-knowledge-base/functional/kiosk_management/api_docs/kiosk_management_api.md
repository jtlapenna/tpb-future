---
title: Kiosk Management API Documentation
description: Detailed documentation of the API endpoints for kiosk management, including request/response examples
last_updated: 2023-08-16
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosk_layouts_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosk_products_controller.rb
tags:
  - api
  - kiosk
  - management
  - endpoints
ai_agent_relevance:
  - KioskManagementAgent
  - IntegrationSpecialistAgent
---

# Kiosk Management API Documentation

## Overview

This document provides detailed information about the API endpoints used for kiosk management in The Peak Beyond's system. These endpoints enable the creation, configuration, and management of kiosks, including layout configuration, product association, and RFID integration.

## Authentication

All API endpoints require authentication using JSON Web Tokens (JWT). The token must be included in the `Authorization` header of each request.

```
Authorization: Bearer <jwt_token>
```

## Base URL

All API endpoints are relative to the base URL of the API server:

```
https://api.thepeakbeyond.com/api/v1
```

## Response Format

All responses are returned in JSON format. Successful responses typically include:

```json
{
  "data": {
    // Resource data
  },
  "meta": {
    // Metadata about the response
  }
}
```

Error responses include:

```json
{
  "errors": [
    {
      "code": "error_code",
      "detail": "Error message"
    }
  ]
}
```

## Kiosk Management Endpoints

### List All Kiosks

Retrieves a list of all kiosks accessible to the authenticated user.

**Endpoint:** `GET /kiosks`

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `store_id` | integer | No | Filter kiosks by store ID |
| `status` | string | No | Filter kiosks by status (active, inactive) |
| `page` | integer | No | Page number for pagination |
| `per_page` | integer | No | Number of items per page |

**Response:**

```json
{
  "data": [
    {
      "id": 1,
      "type": "kiosk",
      "attributes": {
        "name": "Main Entrance Kiosk",
        "store_id": 5,
        "status": "active",
        "created_at": "2023-01-15T10:30:00Z",
        "updated_at": "2023-07-20T14:45:00Z"
      },
      "relationships": {
        "store": {
          "data": {
            "id": 5,
            "type": "store"
          }
        },
        "kiosk_layout": {
          "data": {
            "id": 12,
            "type": "kiosk_layout"
          }
        }
      }
    },
    {
      "id": 2,
      "type": "kiosk",
      "attributes": {
        "name": "Product Display Kiosk",
        "store_id": 5,
        "status": "active",
        "created_at": "2023-02-10T09:15:00Z",
        "updated_at": "2023-07-25T11:20:00Z"
      },
      "relationships": {
        "store": {
          "data": {
            "id": 5,
            "type": "store"
          }
        },
        "kiosk_layout": {
          "data": {
            "id": 15,
            "type": "kiosk_layout"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 12,
    "page": 1,
    "per_page": 10
  }
}
```

### Create a New Kiosk

Creates a new kiosk in the system.

**Endpoint:** `POST /kiosks`

**Request Body:**

```json
{
  "kiosk": {
    "name": "New Product Display Kiosk",
    "store_id": 5,
    "status": "active",
    "layout_template_id": 3
  }
}
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name of the kiosk |
| `store_id` | integer | ID of the store where the kiosk is located |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | Status of the kiosk (active, inactive) |
| `layout_template_id` | integer | ID of the layout template to use |

**Response:**

```json
{
  "data": {
    "id": 13,
    "type": "kiosk",
    "attributes": {
      "name": "New Product Display Kiosk",
      "store_id": 5,
      "status": "active",
      "created_at": "2023-08-16T10:30:00Z",
      "updated_at": "2023-08-16T10:30:00Z"
    },
    "relationships": {
      "store": {
        "data": {
          "id": 5,
          "type": "store"
        }
      },
      "kiosk_layout": {
        "data": {
          "id": 25,
          "type": "kiosk_layout"
        }
      }
    }
  }
}
```

### Get a Specific Kiosk

Retrieves details for a specific kiosk.

**Endpoint:** `GET /kiosks/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | ID of the kiosk to retrieve |

**Response:**

```json
{
  "data": {
    "id": 1,
    "type": "kiosk",
    "attributes": {
      "name": "Main Entrance Kiosk",
      "store_id": 5,
      "status": "active",
      "created_at": "2023-01-15T10:30:00Z",
      "updated_at": "2023-07-20T14:45:00Z"
    },
    "relationships": {
      "store": {
        "data": {
          "id": 5,
          "type": "store"
        }
      },
      "kiosk_layout": {
        "data": {
          "id": 12,
          "type": "kiosk_layout"
        }
      }
    }
  }
}
```

### Update a Kiosk

Updates an existing kiosk.

**Endpoint:** `PUT /kiosks/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | ID of the kiosk to update |

**Request Body:**

```json
{
  "kiosk": {
    "name": "Updated Kiosk Name",
    "status": "inactive"
  }
}
```

**Response:**

```json
{
  "data": {
    "id": 1,
    "type": "kiosk",
    "attributes": {
      "name": "Updated Kiosk Name",
      "store_id": 5,
      "status": "inactive",
      "created_at": "2023-01-15T10:30:00Z",
      "updated_at": "2023-08-16T11:45:00Z"
    },
    "relationships": {
      "store": {
        "data": {
          "id": 5,
          "type": "store"
        }
      },
      "kiosk_layout": {
        "data": {
          "id": 12,
          "type": "kiosk_layout"
        }
      }
    }
  }
}
```

### Clone a Kiosk

Creates a new kiosk by cloning an existing one.

**Endpoint:** `POST /kiosks/:id/clone`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | ID of the kiosk to clone |

**Request Body:**

```json
{
  "kiosk": {
    "name": "Cloned Kiosk",
    "store_id": 6
  }
}
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name of the new cloned kiosk |
| `store_id` | integer | ID of the store for the new kiosk |

**Response:**

```json
{
  "data": {
    "id": 14,
    "type": "kiosk",
    "attributes": {
      "name": "Cloned Kiosk",
      "store_id": 6,
      "status": "active",
      "created_at": "2023-08-16T12:30:00Z",
      "updated_at": "2023-08-16T12:30:00Z"
    },
    "relationships": {
      "store": {
        "data": {
          "id": 6,
          "type": "store"
        }
      },
      "kiosk_layout": {
        "data": {
          "id": 26,
          "type": "kiosk_layout"
        }
      }
    }
  }
}
```

## Kiosk Layout Endpoints

### Get a Specific Kiosk Layout

Retrieves details for a specific kiosk layout.

**Endpoint:** `GET /kiosk_layouts/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | ID of the kiosk layout to retrieve |

**Response:**

```json
{
  "data": {
    "id": 12,
    "type": "kiosk_layout",
    "attributes": {
      "kiosk_id": 1,
      "template_id": 3,
      "home_layout": "grid",
      "navigation_style": "tabbed",
      "welcome_message": "Welcome to our store! Tap a product to learn more.",
      "background_color": "#f5f5f5",
      "primary_color": "#4a90e2",
      "secondary_color": "#50e3c2",
      "font_family": "Roboto",
      "created_at": "2023-01-15T10:30:00Z",
      "updated_at": "2023-07-20T14:45:00Z"
    },
    "relationships": {
      "kiosk": {
        "data": {
          "id": 1,
          "type": "kiosk"
        }
      },
      "template": {
        "data": {
          "id": 3,
          "type": "template"
        }
      },
      "assets": {
        "data": [
          {
            "id": 45,
            "type": "asset"
          },
          {
            "id": 67,
            "type": "asset"
          }
        ]
      }
    }
  }
}
```

### Update a Kiosk Layout

Updates an existing kiosk layout.

**Endpoint:** `PUT /kiosk_layouts/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | ID of the kiosk layout to update |

**Request Body:**

```json
{
  "kiosk_layout": {
    "template_id": 4,
    "home_layout": "list",
    "navigation_style": "sidebar",
    "welcome_message": "Updated welcome message",
    "background_color": "#ffffff",
    "primary_color": "#3498db",
    "secondary_color": "#2ecc71"
  }
}
```

**Response:**

```json
{
  "data": {
    "id": 12,
    "type": "kiosk_layout",
    "attributes": {
      "kiosk_id": 1,
      "template_id": 4,
      "home_layout": "list",
      "navigation_style": "sidebar",
      "welcome_message": "Updated welcome message",
      "background_color": "#ffffff",
      "primary_color": "#3498db",
      "secondary_color": "#2ecc71",
      "font_family": "Roboto",
      "created_at": "2023-01-15T10:30:00Z",
      "updated_at": "2023-08-16T13:15:00Z"
    },
    "relationships": {
      "kiosk": {
        "data": {
          "id": 1,
          "type": "kiosk"
        }
      },
      "template": {
        "data": {
          "id": 4,
          "type": "template"
        }
      },
      "assets": {
        "data": [
          {
            "id": 45,
            "type": "asset"
          },
          {
            "id": 67,
            "type": "asset"
          }
        ]
      }
    }
  }
}
```

## Kiosk Product Endpoints

### List Products Associated with a Kiosk

Retrieves a list of products associated with a specific kiosk.

**Endpoint:** `GET /kiosks/:kiosk_id/kiosk_products`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `category_id` | integer | No | Filter products by category ID |
| `brand_id` | integer | No | Filter products by brand ID |
| `page` | integer | No | Page number for pagination |
| `per_page` | integer | No | Number of items per page |

**Response:**

```json
{
  "data": [
    {
      "id": 123,
      "type": "kiosk_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 456,
        "position": 1,
        "featured": true,
        "created_at": "2023-02-15T10:30:00Z",
        "updated_at": "2023-07-20T14:45:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 456,
            "type": "product"
          }
        }
      }
    },
    {
      "id": 124,
      "type": "kiosk_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 457,
        "position": 2,
        "featured": false,
        "created_at": "2023-02-15T10:35:00Z",
        "updated_at": "2023-07-20T14:50:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 457,
            "type": "product"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 45,
    "page": 1,
    "per_page": 10
  }
}
```

### Associate Products with a Kiosk

Associates one or more products with a kiosk.

**Endpoint:** `POST /kiosks/:kiosk_id/kiosk_products`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |

**Request Body:**

```json
{
  "kiosk_products": [
    {
      "product_id": 458,
      "position": 3,
      "featured": true
    },
    {
      "product_id": 459,
      "position": 4,
      "featured": false
    }
  ]
}
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `product_id` | integer | ID of the product to associate |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `position` | integer | Display position of the product |
| `featured` | boolean | Whether the product is featured |

**Response:**

```json
{
  "data": [
    {
      "id": 125,
      "type": "kiosk_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 458,
        "position": 3,
        "featured": true,
        "created_at": "2023-08-16T14:30:00Z",
        "updated_at": "2023-08-16T14:30:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 458,
            "type": "product"
          }
        }
      }
    },
    {
      "id": 126,
      "type": "kiosk_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 459,
        "position": 4,
        "featured": false,
        "created_at": "2023-08-16T14:30:00Z",
        "updated_at": "2023-08-16T14:30:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 459,
            "type": "product"
          }
        }
      }
    }
  ]
}
```

### Get a Specific Kiosk Product

Retrieves details for a specific kiosk product association.

**Endpoint:** `GET /kiosks/:kiosk_id/kiosk_products/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |
| `id` | integer | ID of the kiosk product association |

**Response:**

```json
{
  "data": {
    "id": 123,
    "type": "kiosk_product",
    "attributes": {
      "kiosk_id": 1,
      "product_id": 456,
      "position": 1,
      "featured": true,
      "created_at": "2023-02-15T10:30:00Z",
      "updated_at": "2023-07-20T14:45:00Z"
    },
    "relationships": {
      "kiosk": {
        "data": {
          "id": 1,
          "type": "kiosk"
        }
      },
      "product": {
        "data": {
          "id": 456,
          "type": "product"
        }
      }
    }
  }
}
```

### Update a Kiosk Product

Updates a specific kiosk product association.

**Endpoint:** `PUT /kiosks/:kiosk_id/kiosk_products/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |
| `id` | integer | ID of the kiosk product association |

**Request Body:**

```json
{
  "kiosk_product": {
    "position": 5,
    "featured": true
  }
}
```

**Response:**

```json
{
  "data": {
    "id": 123,
    "type": "kiosk_product",
    "attributes": {
      "kiosk_id": 1,
      "product_id": 456,
      "position": 5,
      "featured": true,
      "created_at": "2023-02-15T10:30:00Z",
      "updated_at": "2023-08-16T15:20:00Z"
    },
    "relationships": {
      "kiosk": {
        "data": {
          "id": 1,
          "type": "kiosk"
        }
      },
      "product": {
        "data": {
          "id": 456,
          "type": "product"
        }
      }
    }
  }
}
```

### Remove a Product from a Kiosk

Removes a product association from a kiosk.

**Endpoint:** `DELETE /kiosks/:kiosk_id/kiosk_products/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |
| `id` | integer | ID of the kiosk product association |

**Response:**

```
Status: 204 No Content
```

## RFID Management Endpoints

### List RFID Products for a Kiosk

Retrieves a list of RFID product associations for a specific kiosk.

**Endpoint:** `GET /kiosks/:kiosk_id/rfid_products`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | integer | No | Page number for pagination |
| `per_page` | integer | No | Number of items per page |

**Response:**

```json
{
  "data": [
    {
      "id": 78,
      "type": "rfid_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 456,
        "rfid_tag": "A1B2C3D4E5F6",
        "created_at": "2023-03-15T10:30:00Z",
        "updated_at": "2023-07-20T14:45:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 456,
            "type": "product"
          }
        }
      }
    },
    {
      "id": 79,
      "type": "rfid_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 457,
        "rfid_tag": "F6E5D4C3B2A1",
        "created_at": "2023-03-15T10:35:00Z",
        "updated_at": "2023-07-20T14:50:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 457,
            "type": "product"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 25,
    "page": 1,
    "per_page": 10
  }
}
```

### Create RFID Product Associations

Associates RFID tags with products for a kiosk.

**Endpoint:** `POST /kiosks/:kiosk_id/rfid_products`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |

**Request Body:**

```json
{
  "rfid_products": [
    {
      "product_id": 458,
      "rfid_tag": "1A2B3C4D5E6F"
    },
    {
      "product_id": 459,
      "rfid_tag": "6F5E4D3C2B1A"
    }
  ]
}
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `product_id` | integer | ID of the product to associate |
| `rfid_tag` | string | RFID tag identifier |

**Response:**

```json
{
  "data": [
    {
      "id": 80,
      "type": "rfid_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 458,
        "rfid_tag": "1A2B3C4D5E6F",
        "created_at": "2023-08-16T16:30:00Z",
        "updated_at": "2023-08-16T16:30:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 458,
            "type": "product"
          }
        }
      }
    },
    {
      "id": 81,
      "type": "rfid_product",
      "attributes": {
        "kiosk_id": 1,
        "product_id": 459,
        "rfid_tag": "6F5E4D3C2B1A",
        "created_at": "2023-08-16T16:30:00Z",
        "updated_at": "2023-08-16T16:30:00Z"
      },
      "relationships": {
        "kiosk": {
          "data": {
            "id": 1,
            "type": "kiosk"
          }
        },
        "product": {
          "data": {
            "id": 459,
            "type": "product"
          }
        }
      }
    }
  ]
}
```

### Update RFID Product Association

Updates an RFID product association.

**Endpoint:** `PUT /kiosks/:kiosk_id/rfid_products/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |
| `id` | integer | ID of the RFID product association |

**Request Body:**

```json
{
  "rfid_product": {
    "rfid_tag": "UPDATED1A2B3C4D"
  }
}
```

**Response:**

```json
{
  "data": {
    "id": 80,
    "type": "rfid_product",
    "attributes": {
      "kiosk_id": 1,
      "product_id": 458,
      "rfid_tag": "UPDATED1A2B3C4D",
      "created_at": "2023-08-16T16:30:00Z",
      "updated_at": "2023-08-16T17:15:00Z"
    },
    "relationships": {
      "kiosk": {
        "data": {
          "id": 1,
          "type": "kiosk"
        }
      },
      "product": {
        "data": {
          "id": 458,
          "type": "product"
        }
      }
    }
  }
}
```

### Remove RFID Product Association

Removes an RFID product association.

**Endpoint:** `DELETE /kiosks/:kiosk_id/rfid_products/:id`

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `kiosk_id` | integer | ID of the kiosk |
| `id` | integer | ID of the RFID product association |

**Response:**

```
Status: 204 No Content
```

## Error Codes

| Code | Description |
|------|-------------|
| `unauthorized` | Authentication failed or token is invalid |
| `forbidden` | User does not have permission to access the resource |
| `not_found` | The requested resource was not found |
| `validation_error` | The request contains invalid data |
| `server_error` | An unexpected error occurred on the server |

## Rate Limiting

API requests are subject to rate limiting to ensure system stability. The current limits are:

- 100 requests per minute per API token
- 5,000 requests per day per API token

Rate limit information is included in the response headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1629123600
```

## Pagination

List endpoints support pagination using the `page` and `per_page` query parameters. The default page size is 10 items, with a maximum of 100 items per page.

Pagination metadata is included in the response:

```json
"meta": {
  "total_count": 45,
  "page": 1,
  "per_page": 10,
  "total_pages": 5
}
```

## Versioning

The API is versioned using the URL path (e.g., `/api/v1`). When a new version is released, the previous version will be maintained for a deprecation period before being removed.

## Changelog

### v1.0.0 (2023-01-01)
- Initial release of the Kiosk Management API

### v1.1.0 (2023-04-15)
- Added RFID product management endpoints
- Improved error handling and validation

### v1.2.0 (2023-07-01)
- Added kiosk cloning functionality
- Enhanced pagination and filtering options 