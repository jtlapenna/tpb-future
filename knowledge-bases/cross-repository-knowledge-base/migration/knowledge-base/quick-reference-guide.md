# Quick Reference Guide for Key Concepts

## Overview
This document provides concise definitions and explanations of key concepts, terminology, and architectural principles used throughout the migration documentation. It serves as a quick reference for team members to ensure consistent understanding of important concepts.

## System Architecture Concepts

### Monolith vs. Microservices

**Monolith**
- Single, unified codebase
- Shared database
- Deployed as a single unit
- Examples: Current Rails backend

**Microservices**
- Distributed, independent services
- Service-specific databases
- Independent deployment
- Examples: Target architecture for some components

### API Architectural Styles

**REST (Representational State Transfer)**
- Resource-oriented
- Uses standard HTTP methods (GET, POST, PUT, DELETE)
- Stateless interactions
- Used in: Current backend API, proposed new services

**GraphQL**
- Query language for APIs
- Single endpoint, client-specified data retrieval
- Reduces over-fetching and under-fetching
- Consideration for: New frontend data requirements

**Event-Driven**
- Communication via events
- Publishers and subscribers
- Asynchronous processing
- Proposed for: Inter-service communication in new architecture

## Database Concepts

### Relational vs. NoSQL

**Relational Database**
- Structured schema
- ACID transactions
- SQL query language
- Examples: PostgreSQL, MySQL

**NoSQL Database**
- Flexible schema
- Horizontal scaling
- Various data models (document, key-value, column, graph)
- Examples: MongoDB, Redis, Cassandra

### Database Patterns

**Sharding**
- Horizontal partitioning of data
- Distributes data across multiple databases
- Improves scalability and performance

**Read Replicas**
- Copies of primary database for read operations
- Reduces load on primary database
- Improves read performance and availability

**Command Query Responsibility Segregation (CQRS)**
- Separates read and write operations
- Different models for querying and updating
- Enables optimization for different workloads

## Frontend Development Concepts

### Rendering Approaches

**Client-Side Rendering (CSR)**
- Browser renders content using JavaScript
- Initial load can be slower, subsequent navigation faster
- Examples: Current Vue.js frontend

**Server-Side Rendering (SSR)**
- Server renders HTML
- Faster initial page load, better SEO
- Examples: Proposed approach for new frontend

**Static Site Generation (SSG)**
- Pages pre-rendered at build time
- Very fast loading, excellent SEO
- Suitable for: Content-heavy pages with infrequent updates

### State Management

**Flux/Redux Pattern**
- Unidirectional data flow
- Single source of truth
- Actions, reducers, store
- Used in: Some parts of current frontend

**Reactive State**
- Observable/reactive data
- Automatic UI updates when data changes
- Examples: Vue.js reactive system

## DevOps Concepts

### Deployment Strategies

**Blue-Green Deployment**
- Two identical environments (blue and green)
- Traffic switched from one to another
- Enables zero-downtime deployments
- Proposed for: New system deployment

**Canary Releases**
- Gradual rollout to a subset of users
- Monitors for issues before full deployment
- Reduces risk of deployment issues
- Recommended for: High-risk feature deployments

**Feature Flags**
- Code paths controlled by configuration
- Enables or disables features without deployment
- Allows for controlled feature rollout
- Planned for: Migration transition period

### CI/CD Concepts

**Continuous Integration (CI)**
- Frequent code integration into shared repository
- Automated building and testing
- Prevents integration problems
- Required for: New development workflow

**Continuous Delivery (CD)**
- Automated deployment to staging/production
- Ensures software is always in releasable state
- Reduces deployment risk and effort
- Target for: New development pipeline

## Data Migration Concepts

### Migration Strategies

**Big Bang Migration**
- Complete switch from old to new system at once
- Higher risk, shorter timeline
- Not recommended for this project

**Incremental Migration**
- Phased approach
- Systems coexist during transition
- Lower risk, longer timeline
- Proposed approach for this project

**Strangler Pattern**
- Gradually replace functionality
- Old and new systems run in parallel
- Eventually "strangle" the old system
- Key strategy for: API migration

### Data Transformation Patterns

**Extract-Transform-Load (ETL)**
- Extract data from source
- Transform to target schema
- Load into destination
- Used for: Initial data migration

**Change Data Capture (CDC)**
- Tracks changes in source database
- Replicates changes to target system
- Enables incremental data synchronization
- Planned for: Keeping systems in sync during migration

## Security Concepts

### Authentication Methods

**Token-Based Authentication**
- Client receives token after authentication
- Token used for subsequent requests
- Example: JWT (JSON Web Tokens)
- Current implementation: Custom token solution

**OAuth 2.0**
- Authorization framework
- Enables third-party access
- Different grant types for different scenarios
- Consideration for: New authentication system

### Security Design Principles

**Defense in Depth**
- Multiple layers of security controls
- No single point of failure
- Comprehensive protection strategy

**Least Privilege**
- Users/systems have minimal access needed
- Reduces attack surface and impact of breaches
- Critical for: New permission system

**Zero Trust**
- No implicit trust based on network location
- Continuous verification of every access attempt
- "Never trust, always verify"
- Target model for: New security architecture

## Quality Assurance Concepts

### Testing Pyramid

**Unit Tests**
- Test individual components/functions
- Fast, numerous
- Foundation of testing strategy

**Integration Tests**
- Test interactions between components
- Verify correct communication and data flow
- Middle layer of testing strategy

**End-to-End Tests**
- Test complete workflows
- Simulate real user behavior
- Top of pyramid, fewer but comprehensive

### QA Methodologies

**Test-Driven Development (TDD)**
- Write tests before implementing features
- Red-Green-Refactor cycle
- Ensures testable code
- Recommended for: Critical business logic

**Behavior-Driven Development (BDD)**
- Focuses on business behavior
- Uses natural language specifications
- Bridges communication gap between technical and non-technical team members
- Approach for: Feature validation with stakeholders

## Business Domain Concepts

### Core Business Entities

**Product**
- Items available for purchase
- Attributes: SKU, price, description, image
- Relationships: Categories, variants, inventory

**Order**
- Customer purchase transaction
- Components: Line items, payment, shipping details
- States: Created, processed, fulfilled, completed

**Customer**
- User who makes purchases
- Attributes: Contact info, preferences, purchase history
- Relationships: Orders, carts, payment methods

**Inventory**
- Stock levels of products
- Attributes: Quantity, location, availability
- Operations: Reservation, allocation, adjustment

## Reference Information

### Current System Components

**Rails Backend**
- Ruby on Rails monolith application
- RESTful API + server-rendered admin views
- PostgreSQL database
- Business logic and data access

**Vue.js Frontend**
- Single-page application (SPA)
- Consumer-facing storefront
- Communicates with backend via API

**Angular CMS**
- Content management system
- Admin interface for content editors
- Uses backend API for data operations

### Target Architecture Components

**API Gateway**
- Entry point for client applications
- Request routing, authentication, rate limiting
- Unified interface to backend services

**Microservices**
- Product Service, Order Service, Customer Service
- Bounded contexts with dedicated databases
- Independent scaling and deployment

**Shared Components Library**
- Reusable UI components
- Consistent design language
- Used across all frontend applications

## Using This Guide

- Use as a quick reference when reviewing documentation
- Refer to linked detailed documentation for in-depth understanding
- Suggest additions or clarifications via the contribution process

## Related Documentation
- [Knowledge Base Index](index.md) - Main knowledge base entry point
- [Patterns and Findings Index](patterns-index.md) - Detailed pattern reference
- [High-Level Architecture](../architecture/high-level-architecture.md) - Architecture details 