# The Peak Beyond - Master Glossary

## Overview
This document serves as the centralized glossary for The Peak Beyond's system, combining both system-wide terminology and domain-specific terms. Terms are organized hierarchically by domain, with cross-references where appropriate.

## Document Structure
- Terms are organized alphabetically within each section
- Domain-specific terms include their context in parentheses
- Cross-references are indicated with "See also: [term]"
- Each term includes:
  - Definition
  - Context (if domain-specific)
  - Related terms
  - Usage examples (where helpful)

## System-Wide Terms

### A

#### API (Application Programming Interface)
A set of rules and protocols that allows different software applications to communicate with each other. In The Peak Beyond's system, APIs enable communication between the backend, frontend, and third-party systems.
*See also: Backend, Frontend*

#### Authentication
The process of verifying the identity of a user, system, or entity. The Peak Beyond's system uses JWT-based authentication for API access.
*See also: JWT, Authorization*

#### Authorization
The process of determining whether an authenticated user has permission to access specific resources or perform specific actions.
*See also: Authentication*

### B

#### Backend
The server-side component of The Peak Beyond's system, responsible for data processing, business logic, and API services.
*See also: API, Frontend*

#### Batch Synchronization
A process where data is synchronized between systems in scheduled batches rather than in real-time.
*See also: Incremental Synchronization, StoreSync*

### C

#### CMS (Content Management System)
The system used to manage digital content for The Peak Beyond's kiosks, including product information, promotions, and media assets.
*See also: Kiosk*

#### Circuit Breaker Pattern
A design pattern used to detect failures and prevent cascading failures in distributed systems by "tripping" when a certain threshold of failures is reached.
*See also: Fallback Mechanism*

#### Controller
A component in the MVC architecture that handles user input and updates the model and view accordingly.
*See also: Model*

### D

#### Data Model
The structure and organization of data within The Peak Beyond's system, including entities, attributes, and relationships.
*See also: Entity, ERD*

#### Dispensary
A retail location that sells cannabis products, which is a primary client of The Peak Beyond's system.
*See also: Store, Tenant*

#### Dutchie
A cannabis e-commerce platform that integrates with The Peak Beyond's system.
*See also: Integration, POS*

## Domain-Specific Terms

### Kiosk Management

#### Asset (Kiosk)
Digital media (image, video, audio) used in kiosk layouts to enhance the visual experience.
*See also: CMS*

#### Brand (Kiosk)
A company that produces cannabis products, used for organizing and filtering products on kiosks.
*See also: Product*

#### Category (Kiosk)
A classification for products (e.g., flower, edibles, concentrates) used for organizing and filtering products on kiosks.
*See also: Product*

#### Clone (Kiosk)
The process of creating a new kiosk based on the configuration of an existing one.
*See also: Kiosk Layout*

#### Content Manager (Kiosk)
A user role with permissions to manage content and layout configuration for kiosks.
*See also: Store Manager, System Administrator*

#### Device Certificate (Kiosk)
A digital certificate used to authenticate a kiosk device to the backend system.
*See also: Authentication*

#### Device Identifier (Kiosk)
A unique identifier assigned to each physical kiosk device for authentication and tracking purposes.
*See also: Authentication*

#### Featured Product (Kiosk)
A product that is highlighted or given prominent placement on a kiosk interface.
*See also: Product*

#### Heartbeat (Kiosk)
A periodic signal sent from a kiosk to the backend to indicate that it is online and functioning.
*See also: WebSocket*

#### Home Layout (Kiosk)
The layout style used for the main screen of a kiosk (grid, list, or carousel).
*See also: Kiosk Layout*

#### Kiosk Layout
The visual configuration and appearance settings for a kiosk interface.
*See also: Layout Template*

#### Kiosk Product
An association between a kiosk and a product, determining which products are displayed on a specific kiosk.
*See also: Product, Product Association*

#### Layout Editor (Kiosk)
The interface used to configure the visual appearance and behavior of a kiosk.
*See also: Kiosk Layout*

#### Layout Template (Kiosk)
A predefined layout structure that can be applied to a kiosk to ensure consistent design.
*See also: Kiosk Layout*

#### Navigation Style (Kiosk)
The method used for navigating between different sections of the kiosk interface (tabbed, sidebar, or dropdown).
*See also: UI*

#### Position (Kiosk)
The display order of a product on a kiosk interface.
*See also: Product Association*

#### Product Association (Kiosk)
The process of linking products to a kiosk to determine which products are displayed.
*See also: Kiosk Product*

#### Product Filtering (Kiosk)
The process of automatically selecting which products to display on a kiosk based on defined criteria.
*See also: Product Association*

#### RFID Product (Kiosk)
An association between an RFID tag and a product for a specific kiosk.
*See also: RFID Tag*

#### RFID Tag (Kiosk)
A small electronic device containing a chip and an antenna that can be attached to a product for identification.
*See also: RFID Product*

#### Welcome Message (Kiosk)
A customizable text displayed on the kiosk home screen to greet customers.
*See also: Home Layout*

### User Management

#### Access Control (Security)
A system that controls and manages user access to resources based on roles and permissions.
*See also: RBAC, Authorization*

#### Account Lockout (Security)
A security measure that temporarily disables a user account after a specified number of failed login attempts.
*See also: Authentication*

#### API User (Security)
A special user role that provides programmatic access for machine-to-machine interactions.
*See also: Authentication, Authorization*

#### Audit Logging (Security)
The process of recording authentication, authorization, and user management events for security monitoring and compliance.
*See also: Security Monitoring*

#### Failed Login Attempt (Security)
An unsuccessful attempt to authenticate to the system, which may trigger security measures like account lockout.
*See also: Account Lockout, Authentication*

#### Multi-factor Authentication (MFA) (Security)
An authentication method that requires users to provide two or more verification factors to gain access.
*See also: Authentication*

#### Password Hash (Security)
A secure, one-way transformation of a password using bcrypt, ensuring passwords are never stored in plaintext.
*See also: Authentication*

#### Permission (Security)
A specific access right that can be assigned to roles, controlling what actions users can perform.
*See also: Role, RBAC*

#### Pundit Policy (Security)
A Ruby gem-based implementation of authorization policies that enforce access controls.
*See also: Authorization*

#### RBAC (Role-Based Access Control) (Security)
A method of restricting system access based on user roles and their associated permissions.
*See also: Role, Permission*

#### Role (Security)
A collection of permissions that define what actions a user can perform. The system has four primary roles:
- System Administrator
- Store Manager
- Store Staff
- API User
*See also: Permission, RBAC*

#### Security Monitoring (Security)
The continuous observation and logging of system security events for audit and compliance purposes.
*See also: Audit Logging*

#### Single Sign-On (SSO) (Security)
A planned authentication feature that will allow users to access multiple systems with a single set of credentials.
*See also: Authentication*

#### Store Manager (Security)
A user role responsible for managing store staff accounts and store-specific security settings.
*See also: Role, RBAC*

#### System Administrator (Security)
A user role with full access to manage all user accounts, roles, and system-wide security settings.
*See also: Role, RBAC*

### Order Management

#### Cart (Order)
A temporary collection of products that a customer intends to purchase.
*See also: Order, Product*

#### Customer Order
A database model storing order information including customer details, order status, and payment information.
*See also: Order, OrderCustomer*

#### Order
A transaction representing a customer's purchase of products from a dispensary.
*See also: OrderItem, CustomerOrder*

#### Order Creation
The process of converting a cart into an order and submitting it to the POS system.
*See also: Cart, POS*

#### Order Fulfillment
The process of completing an order, including product preparation and delivery/pickup.
*See also: Order Status*

#### Order Item
An individual product within an order, including quantity and pricing details.
*See also: Order, Product*

#### Order Processing
The workflow of handling an order from creation to fulfillment.
*See also: Order Creation, Order Fulfillment*

#### Order Status
The current state of an order in its lifecycle (e.g., "IN_PROCESS", "PACKED_READY", "COMPLETED", "CANCELED").
*See also: Order Processing*

#### Order Validation
The process of checking order details for validity, including inventory availability and purchase limits.
*See also: Inventory Management*

### Customer Management

#### Customer
A person who makes purchases from a dispensary through The Peak Beyond's system.
*See also: CustomerOrder, Store*

#### Customer Order
An association between a customer and their orders, tracking purchase history and preferences.
*See also: Order, Customer*

#### Customer Sync
The process of synchronizing customer data between The Peak Beyond's system and POS systems.
*See also: POS, Synchronization*

#### Customer Type
A classification of customers that determines applicable tax rates and purchase limits.
*See also: Tax Customer Type*

#### Customer Verification
The process of validating a customer's identity and eligibility to purchase products.
*See also: Verification Status*

#### Tax Customer Type
A category that determines which tax rates apply to a customer's purchases.
*See also: Customer Type*

#### Verification Status
The current state of a customer's verification process (e.g., verified, pending, failed).
*See also: Customer Verification*

### Inventory Management

#### Batch Synchronization (Inventory)
A process where inventory data is synchronized between systems in scheduled batches.
*See also: Synchronization, POS*

#### Inventory Level
The current quantity of a product available for sale in a store.
*See also: StoreProduct*

#### Inventory Management Service
A service responsible for managing product stock levels, synchronization, and alerts.
*See also: StoreProduct, POS*

#### Inventory Status
The current state of a product's inventory (e.g., in stock, low stock, out of stock).
*See also: Inventory Level*

#### Inventory Type
A classification of inventory (e.g., medical, recreational) that determines how it's tracked and sold.
*See also: StoreProduct*

#### Stock Alert
A notification triggered when inventory levels reach defined thresholds.
*See also: Inventory Level*

#### Store Product
A representation of a product within a specific store, including store-specific attributes like price and inventory.
*See also: Product, Store*

#### Store Product Promotion
A promotional offer associated with a specific store product.
*See also: Store Product*

#### Store Product Variant
A specific version of a store product with distinct attributes (e.g., size, weight).
*See also: Store Product*

#### Synchronization
The process of keeping inventory data consistent between The Peak Beyond's system and POS systems.
*See also: POS, Batch Synchronization*

## Integration Terms
[To be populated from integration documentation]

## Technical Terms
[To be populated from technical documentation]

## Acronyms

| Acronym | Definition |
|---------|------------|
| API | Application Programming Interface |
| CMS | Content Management System |
| ERD | Entity Relationship Diagram |
| JWT | JSON Web Token |
| POS | Point of Sale |
| UI | User Interface |
| UX | User Experience |

## Usage Conventions

1. Use the exact terms as defined in this glossary throughout all documentation
2. Capitalize proper nouns (e.g., "Treez", "Dutchie") consistently
3. Use full terms on first mention in a document, followed by the acronym in parentheses
4. Use acronyms for subsequent mentions within the same document

## Maintenance
This glossary should be updated whenever:
1. New terms are introduced to the system
2. Existing terms change in meaning or usage
3. New domains or integrations are added
4. Terms become deprecated

## Version History
- Initial structure created during documentation consolidation
- Added system-wide terms from original glossary
- Added kiosk management terms
- Added security-related terms from user management documentation 