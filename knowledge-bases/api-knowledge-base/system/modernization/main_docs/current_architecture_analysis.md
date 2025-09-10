# Current Architecture Analysis

## Overview

This document provides an analysis of the current architecture of The Peak Beyond's system, focusing on the backend and frontend components, their interactions, and the overall system design. This analysis serves as the foundation for modernization recommendations.

## System Components

The Peak Beyond's software ecosystem consists of four core repositories:

| Repository | Primary Role | Technology | Key Responsibilities |
|------------|-------------|------------|----------------------|
| **Backend (Rails API)** | Central hub for data processing, POS integration, and API services | Ruby on Rails | POS synchronization, order processing, data validation, API services |
| **Frontend (Angular Kiosk UI)** | Touchscreen interface for customer interactions | Angular | Product browsing, NFC/RFID interactions, order submission, real-time updates |
| **CMS (Angular)** | Admin panel for managing products, pricing, and content | Angular | Product management, pricing, promotions, user management, reporting |
| **Kiosk Install (SysAdmin)** | Manages kiosk deployment, configuration, and updates | Puppet, Bash | Installation, configuration, updates, monitoring, diagnostics |

## Backend Architecture

### Technology Stack

- **Language**: Ruby 2.7.0
- **Framework**: Ruby on Rails 6.0.2
- **Database**: PostgreSQL
- **API Format**: JSON REST API
- **Authentication**: JWT (JSON Web Tokens) via Knock gem
- **Authorization**: Pundit
- **Background Processing**: Sidekiq with Redis
- **Testing**: RSpec, Factory Bot, WebMock
- **Linting**: RuboCop
- **Real-time Communication**: WebSockets, Pusher
- **Deployment**: Docker, Docker Compose
- **CI/CD**: CircleCI

### Architectural Patterns

1. **MVC (Model-View-Controller)**: Core Rails pattern separating data, presentation, and control logic
2. **Service Objects**: Complex business logic encapsulated in operation classes
3. **Repository Pattern**: Data access abstracted through models
4. **Policy Objects**: Authorization logic separated using Pundit policies
5. **Serializer Pattern**: Response formatting handled by dedicated serializers
6. **Background Job Processing**: Asynchronous processing using Sidekiq
7. **Event-Driven Architecture**: Real-time updates using WebSockets and Pusher
8. **Multi-Tenant Architecture**: Data isolation by store while sharing common master data

### Key Dependencies

- **active_model_serializers**: JSON serialization for API responses
- **activejob-uniqueness**: Ensures background jobs run only once
- **acts-as-taggable-on**: Tagging functionality for products
- **airbrake**: Error monitoring
- **algoliasearch-rails**: Search functionality
- **aws-sdk-s3**: AWS S3 integration for file storage
- **bcrypt**: Secure password hashing
- **dry-monads**: Functional programming patterns
- **dry-validation**: Advanced validation logic
- **httparty**: HTTP client for API integrations
- **kaminari**: Pagination
- **knock**: JWT authentication
- **paper_trail**: Object versioning and history
- **pusher**: Real-time updates
- **pundit**: Authorization policies
- **sidekiq**: Background job processing
- **sidekiq-cron**: Scheduled background jobs
- **twilio-ruby**: SMS notifications
- **shopify_api**: Shopify integration

## Frontend Architecture

### Technology Stack

- **Framework**: Angular
- **Language**: TypeScript
- **UI Components**: Custom components with Angular Material
- **State Management**: Likely NgRx
- **API Communication**: Angular HttpClient
- **Real-time Updates**: Pusher
- **Styling**: SCSS
- **Build System**: Angular CLI
- **Testing**: Jasmine, Karma

### Architectural Patterns

1. **Component-Based Architecture**: Reusable UI components organized in a hierarchical structure
2. **State Management**: NgRx for state management, following the Redux pattern
3. **Service-Based API Integration**: API calls encapsulated in services
4. **Real-Time Communication**: Pusher for real-time updates

## Data Flow Architecture

The system follows a multi-directional data flow between POS systems, the backend, CMS, and kiosk frontends:

```
[POS Systems] ⟷ [API Integration Layer] ⟷ [The Peak Beyond CMS] ⟷ [Kiosk Frontends]
```

### Key Data Flows

1. **POS → CMS → Backend → Kiosk UI Flow (Inventory and Product Data)**
   - Inventory and product information originates in the POS system
   - CMS pulls data from the POS and allows dispensary staff to manage it
   - Backend syncs product and pricing updates from the CMS to the kiosks
   - Frontend fetches data from the backend

2. **Kiosk UI → Backend → POS Flow (Order Processing)**
   - Customers browse and add items to their cart via the Kiosk UI
   - Frontend sends order requests to the backend
   - Backend validates orders and forwards them to the POS system
   - POS confirms orders, and the Backend logs them

3. **Physical Product → Kiosk UI Flow (NFC/RFID Interaction)**
   - NFC-enabled products are tapped on the kiosk
   - Kiosk sends product IDs to the Backend
   - Backend returns product details
   - UI updates to display product information

## Database Architecture

The system uses PostgreSQL with a complex schema containing over 50 tables representing various business entities. Key entity relationships include:

- Stores have many Products
- Products have many Variants
- Kiosks belong to Stores
- Kiosks have many Layouts
- Orders belong to Customers and Stores

The system implements a multi-tenant architecture where Stores are the primary tenant entities, each with its own set of Products, Categories, Kiosks, Customers, Orders, and Content.

## API Structure

The API follows RESTful conventions with versioning:

- **Administrative API**: Used by the management interface
  - Product management
  - Store configuration
  - User management
  - Reporting and analytics

- **Public API (v1)**: Used by kiosk frontends
  - Product retrieval
  - Order submission
  - NFC/RFID interaction
  - Customer management

- **Webhook endpoints**: Receive updates from POS systems
  - Inventory updates
  - Product changes
  - Order status updates

## Real-time Features

The system implements several real-time features using WebSockets, Pusher, and ActionCable:

1. **Product Updates**: Real-time product information updates
2. **Inventory Levels**: Real-time stock level updates
3. **Order Status**: Real-time order status updates
4. **NFC/RFID Interactions**: Immediate UI updates for physical product interactions

## Challenges and Known Issues

| Issue | Description | Potential Solutions |
|-------|-------------|---------------------|
| **POS Sync Delays** | Synchronization with POS systems can experience delays | Predict which POS system is most prone to failure and preemptively adjust sync intervals |
| **Legacy Code Complexity** | Some parts of the codebase have accumulated technical debt | Use code refactoring to identify dead code and improve efficiency |
| **Scaling Challenges** | Database performance issues with increasing data volume | Identify which queries are taking the longest and implement database optimizations |
| **Order Processing Failures** | Orders occasionally fail to submit to POS systems | Implement better error handling and retry mechanisms |
| **Real-time Update Latency** | Updates from POS to kiosks can experience delays | Optimize the synchronization process and implement caching strategies |
| **NFC Scan Failures** | NFC scans occasionally fail to register | Detect patterns in failed scans and recommend hardware recalibration |
| **UI Performance Issues** | UI can lag during large product loads | Optimize data fetching to use progressive rendering |
| **Sync Failures Between CMS and POS** | Data synchronization between CMS and POS can fail | Detect error-prone API calls and suggest retry optimizations |

## Strengths of Current Architecture

1. **Comprehensive POS Integration**: The system integrates with multiple POS systems, providing flexibility for dispensaries.
2. **Real-time Updates**: The use of WebSockets and Pusher enables real-time updates across the system.
3. **Multi-tenant Architecture**: The multi-tenant design allows for efficient management of multiple stores.
4. **Background Job Processing**: Sidekiq provides robust background job processing for asynchronous tasks.
5. **Service-Oriented Design**: The use of service objects and operations encapsulates complex business logic.
6. **Policy-Based Authorization**: Pundit provides a flexible and maintainable authorization system.
7. **Comprehensive Testing**: RSpec and Factory Bot provide a solid testing framework.

## Weaknesses of Current Architecture

1. **Monolithic Backend**: The backend is a monolithic Rails application, which can be challenging to scale and maintain.
2. **Legacy Code Complexity**: Some parts of the codebase have accumulated technical debt.
3. **Scaling Challenges**: The system faces database performance issues with increasing data volume.
4. **Real-time Update Latency**: Updates from POS to kiosks can experience delays.
5. **Angular Frontend**: The Angular frontend may not leverage the latest frontend technologies and patterns.
6. **Limited GraphQL Support**: The system primarily uses REST APIs, which may not be as flexible as GraphQL for complex data requirements.
7. **Deployment Complexity**: The deployment process involves multiple repositories and components.

## Conclusion

The current architecture of The Peak Beyond's system is a comprehensive solution for cannabis retail kiosks, with strengths in POS integration, real-time updates, and multi-tenant design. However, it also faces challenges in scaling, legacy code complexity, and real-time update latency. The next document will explore modernization opportunities to address these challenges and leverage the latest technologies and patterns. 