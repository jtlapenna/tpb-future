---
title: Frontend Architecture Overview
description: High-level overview of The Peak Beyond's frontend architecture
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Frontend Architecture Overview

## Introduction

The Peak Beyond's frontend system consists of two main Angular applications:

1. **Kiosk UI (Frontend)**: Customer-facing touchscreen interface for browsing products and placing orders
2. **CMS (Content Management System)**: Admin-facing interface for managing products, pricing, and content

This document provides a high-level overview of the frontend architecture, focusing on the structure, technologies, and integration patterns.

## Technology Stack

### Core Technologies

- **Framework**: Angular
- **Language**: TypeScript
- **UI Components**: Custom components with Angular Material
- **State Management**: Likely NgRx (to be confirmed)
- **API Communication**: Angular HttpClient
- **Real-time Updates**: Pusher
- **Styling**: SCSS
- **Build System**: Angular CLI
- **Testing**: Jasmine, Karma

### Key Dependencies

- **@angular/core**: Core Angular functionality
- **@angular/material**: Material Design components
- **@angular/router**: Routing functionality
- **pusher-js**: Real-time updates via Pusher
- **rxjs**: Reactive programming library
- **ngx-translate**: Internationalization

## Frontend Applications

### Kiosk UI (Frontend)

The Kiosk UI is a customer-facing application designed for touchscreen interactions in cannabis dispensaries. Key features include:

- **Single-page application (SPA)** optimized for touchscreens
- **NFC and RFID integration** for physical product interactions
- **Progressive web app (PWA)** capabilities
- **Real-time data updates** via Pusher
- **Order submission and checkout flow**
- **Responsive design** for different kiosk sizes

### CMS (Content Management System)

The CMS is an admin-facing application for dispensary staff to manage products, pricing, and content. Key features include:

- **Product and inventory management**
- **POS integration and data syncing**
- **Promotions and discounts management**
- **User management and access control**
- **Reporting and analytics**
- **JWT-based authentication**

## Architecture Patterns

### Component-Based Architecture

Both frontend applications follow a component-based architecture, with reusable UI components organized in a hierarchical structure:

```
App Component
├── Layout Components (Header, Footer, Sidebar)
├── Page Components (Dashboard, Product List, etc.)
│   ├── Feature Components (Product Card, Order Form, etc.)
│   │   ├── UI Components (Button, Input, Modal, etc.)
```

### State Management

The applications likely use NgRx for state management, following the Redux pattern:

- **Store**: Central state container
- **Actions**: Events that trigger state changes
- **Reducers**: Pure functions that update state
- **Selectors**: Functions that extract specific pieces of state
- **Effects**: Handle side effects like API calls

### API Integration

The frontend applications communicate with the backend API using Angular's HttpClient:

- **Service Layer**: Encapsulates API calls in services
- **Interceptors**: Handle authentication, error handling, etc.
- **Models**: TypeScript interfaces matching API responses
- **Adapters**: Transform API responses to application models

### Real-Time Communication

The applications use Pusher for real-time updates:

- **Channel Subscription**: Subscribe to store-specific and kiosk-specific channels
- **Event Handling**: React to events like product updates, inventory changes, etc.
- **UI Updates**: Update the UI in response to real-time events

## Frontend-Backend Integration

### API Communication

The frontend applications communicate with the backend through RESTful API endpoints:

1. **Admin API**: Used by the CMS for administrative operations
   - JWT authentication
   - Full CRUD operations

2. **Public API (v1)**: Used by the Kiosk UI for customer-facing operations
   - Catalog token authentication
   - Primarily read operations with limited write (orders)

### Authentication Flow

#### CMS Authentication

1. User enters credentials in the login form
2. CMS sends credentials to `/user_token` endpoint
3. Backend validates credentials and returns JWT token
4. CMS stores token in local storage or memory
5. CMS includes token in Authorization header for subsequent requests

#### Kiosk Authentication

1. Kiosk is configured with a catalog token during setup
2. Kiosk includes token in requests to the Public API
3. Backend validates token and identifies the kiosk and store

### Data Flow

#### Product Data Flow

1. POS system provides product data to the backend
2. CMS retrieves and displays product data from the backend
3. CMS allows staff to modify product data
4. Backend syncs updated product data to the Kiosk UI
5. Kiosk UI displays product data to customers

#### Order Flow

1. Customer browses products on the Kiosk UI
2. Customer adds products to cart and submits order
3. Kiosk UI sends order to the backend
4. Backend validates and processes the order
5. Backend forwards order to POS system
6. Backend sends confirmation back to Kiosk UI

## Directory Structure

The frontend applications likely follow a standard Angular project structure:

```
src/
├── app/
│   ├── components/
│   │   ├── shared/
│   │   ├── layout/
│   │   └── features/
│   ├── services/
│   ├── models/
│   ├── store/
│   │   ├── actions/
│   │   ├── reducers/
│   │   ├── selectors/
│   │   └── effects/
│   ├── utils/
│   └── app.module.ts
├── assets/
├── environments/
└── index.html
```

## Build and Deployment

The frontend applications are built using Angular CLI and deployed as part of the overall system:

1. **Development**: Local development using `ng serve`
2. **Testing**: Unit tests with Jasmine and Karma
3. **Building**: Production builds with `ng build --prod`
4. **Deployment**: Deployment to kiosks via the Kiosk Install repository

## Performance Considerations

The frontend applications implement several performance optimizations:

1. **Lazy Loading**: Modules are loaded on demand
2. **AOT Compilation**: Ahead-of-time compilation for faster startup
3. **Change Detection Strategy**: OnPush change detection for improved performance
4. **Virtual Scrolling**: For handling large lists of products
5. **Asset Optimization**: Optimized images and assets for touchscreens

## Security Considerations

The frontend applications implement several security measures:

1. **JWT Authentication**: Secure authentication with JWT tokens
2. **XSS Protection**: Angular's built-in XSS protection
3. **CSRF Protection**: Protection against cross-site request forgery
4. **Content Security Policy**: Restrictions on content sources
5. **Secure Storage**: Secure storage of sensitive information

## Next Steps

To complete the frontend architecture documentation, we need to:

1. **Obtain Frontend Codebase Access**: To verify assumptions and gather more details
2. **Analyze Component Structure**: To document the component hierarchy
3. **Examine State Management**: To document the state management approach
4. **Review API Integration**: To document the API integration patterns

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial architecture overview based on system documentation | 