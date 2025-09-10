# The Peak Beyond (TPB) Future Project

## Project Overview

This repository contains The Peak Beyond's comprehensive ecosystem of in-store hardware and software products, strategic planning documents, and analysis artifacts. The project encompasses legacy systems, future planning, and modern e-commerce extensions designed to position TPB as a leader in cannabis retail technology and the emerging AI agent economy.

## Repository Structure

### 📁 `cursor_rules/` - Development Guidelines
**Purpose**: Contains Cursor IDE rules and development guidelines for the legacy code repositories.

**Contents**:
- **`api/rules/`** (268 files): Detailed rules for the Rails backend API, covering models, controllers, serializers, policies, and business logic
- **`cms/rules/`** (84 files): Guidelines for the Angular CMS application, including components, services, and testing patterns  
- **`frontend/rules/`** (140 files): Rules for the Vue.js frontend kiosk application, covering components, state management, and integrations

**Key Features**:
- Comprehensive code quality standards
- API design patterns and conventions
- Testing strategies and best practices
- Security and performance guidelines

---

### 📁 `future-considerations/` - Strategic Planning
**Purpose**: Strategic documents outlining TPB's future direction, stabilization plans, and revenue opportunities.

**Key Documents**:
- **`1_opening_reality_check_opportunity.md`**: Core thesis on retail transformation and TPB's positioning in the AI agent economy
- **`3_strategy_stabilize_v_1_to_seed_v_2_not_wasted_work.md`**: Detailed strategy for stabilizing legacy systems while building V2 foundation
- **`6_user_accounts_as_the_foundation.md`**: User accounts as the keystone for V2 development
- **`7_two_revenue_engines_in_parallel.md`**: Dual revenue strategy (Affiliate/Feeds + Data SaaS/Agent API)
- **`8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`**: Detailed quarterly roadmap for execution
- **`9_target_architecture_appendix.md`**: Target V2 architecture with agent-ready design
- **`11_ask_next_steps.md`**: Immediate action items and approval requirements

**Strategic Focus**:
- Stabilize V1 systems to reduce support burden
- Build V2 foundation with user accounts and modern frontend
- Position as vertical intelligence layer for cannabis retail
- Prepare for AI agent economy integration

---

### 📁 `knowledge-bases/` - AI-Generated Analysis
**Purpose**: Comprehensive LLM analysis of the legacy code repositories, providing detailed documentation and migration guidance.

#### `api-knowledge-base/` - Backend Analysis
- **API Documentation**: Complete API reference with endpoints, authentication, and integration guides
- **System Architecture**: Domain models, data flow, and technical implementation details
- **Functional Documentation**: Feature-specific documentation for products, inventory, orders, and users
- **Technical Patterns**: Background jobs, caching, error handling, and testing strategies

#### `cms-knowledge-base/` - CMS Analysis  
- **Implementation Patterns**: Authentication, HTTP clients, error handling, form validation, and component patterns
- **Architecture Documentation**: System design, integration points, and security considerations
- **Progress Tracking**: Analysis status and completion metrics
- **Migration Guidance**: Patterns for modernizing the Angular CMS

#### `front-end-knowledge-base/` - Frontend Analysis
- **Vue.js Documentation**: Complete analysis of the kiosk frontend application
- **Migration Planning**: Detailed guidance for React migration
- **Functional Areas**: Product browsing, shopping cart, checkout, user authentication
- **Technical Implementation**: State management, testing strategies, build processes

#### `cross-repository-knowledge-base/` - Integration Analysis
- **Cross-Repository Analysis**: Integration patterns between all three repositories
- **Migration Planning**: Comprehensive migration strategy and timeline
- **Patterns Catalog**: Design patterns and anti-patterns across the system
- **Executive Summary**: High-level findings and recommendations

---

### 📁 `repositories/` - Legacy Code Repositories
**Purpose**: The actual legacy code repositories that power TPB's current systems.

#### `back-end/` - Rails API
- **Technology**: Ruby on Rails with PostgreSQL
- **Purpose**: Core API serving kiosk displays and CMS
- **Key Features**: 
  - Product catalog and inventory management
  - POS system integrations (Treez, Leaflogix, Shopify, etc.)
  - User management and authentication
  - Order processing and checkout
- **Status**: Production system requiring stabilization

#### `cms-fe-angular/` - Angular CMS
- **Technology**: Angular 8 with TypeScript
- **Purpose**: Content management system for retailers
- **Key Features**:
  - Kiosk layout management
  - Product catalog administration
  - Store configuration
  - User and client management
- **Status**: Legacy system, new features should go to modern Admin UI

#### `front-end/` - Vue.js Kiosk
- **Technology**: Vue.js 2 with JavaScript
- **Purpose**: Customer-facing kiosk displays
- **Key Features**:
  - Product browsing and search
  - Shopping cart and checkout
  - Offline functionality
  - Analytics and event tracking
- **Status**: Legacy system, target for React migration

---

### 📁 `TPB-Ecomm-FE-and-BE/` - Modern E-commerce Extension
**Purpose**: Unfinished side project demonstrating modern architecture with user accounts and e-commerce capabilities.

#### `ThePeakBeyond_eCommerce/` - React Frontend
- **Technology**: React with TypeScript, Redux for state management
- **Purpose**: Modern e-commerce frontend with user accounts
- **Key Features**:
  - User authentication and profiles
  - Product browsing and favorites
  - Shopping cart and order management
  - Dashboard and purchase history
- **Status**: Incomplete but valuable for V2 reference

#### `ThePeakBeyond_eCommerce_API/` - NestJS Backend
- **Technology**: NestJS with TypeScript
- **Purpose**: Modern API backend with user account support
- **Key Features**:
  - RESTful API design
  - User authentication and authorization
  - Product and inventory management
  - Database integration with Treez
- **Status**: Incomplete but demonstrates modern patterns

---

## Strategic Context

### Current State
TPB operates a successful in-store kiosk business with:
- **Real Market Presence**: Physical kiosks in cannabis dispensaries
- **Unique Dataset**: 8+ years of cannabis retail data and insights
- **Legacy Challenges**: Fragile codebase requiring significant maintenance
- **Growth Opportunity**: Positioned for AI agent economy integration

### Future Vision
The strategic plan focuses on:
1. **Stabilizing V1** while building V2 foundation
2. **User Accounts** as the keystone for personalization and agent integration
3. **Data Enrichment** to create vertical intelligence layer
4. **Dual Revenue Streams**: Affiliate/content feeds + Retail Data SaaS/Agent API
5. **Agent-Ready Architecture** for the emerging AI economy

### Key Success Metrics
- Sync success rate ≥ 99% daily
- Support hours reduction by 25%
- User account adoption and personalization uplift
- API partner adoption and revenue growth
- Agent-ready data feeds and contracts

---

## Getting Started

### For Developers
1. **Legacy Systems**: Start with the knowledge bases for comprehensive documentation
2. **Future Development**: Review future-considerations for strategic context
3. **Modern Patterns**: Examine TPB-Ecomm-FE-and-BE for V2 reference implementations
4. **Development Guidelines**: Follow cursor_rules for consistent code quality

### For Strategic Planning
1. **Current State**: Review knowledge-bases for system understanding
2. **Future Direction**: Study future-considerations for strategic roadmap
3. **Implementation**: Use TPB-Ecomm-FE-and-BE as V2 architecture reference
4. **Execution**: Follow quarterly roadmap in future-considerations

### For AI Agents
1. **System Understanding**: Start with cross-repository-knowledge-base
2. **Code Analysis**: Use individual knowledge bases for specific repositories
3. **Strategic Context**: Review future-considerations for business objectives
4. **Development**: Follow cursor_rules for code generation and modification

---

## Technology Stack

### Legacy Systems
- **Backend**: Ruby on Rails, PostgreSQL, Sidekiq
- **CMS**: Angular 8, TypeScript, Bootstrap
- **Frontend**: Vue.js 2, JavaScript, SCSS

### Modern Extensions
- **Frontend**: React, TypeScript, Redux
- **Backend**: NestJS, TypeScript, PostgreSQL

### Target V2 Architecture
- **Frontend**: Next.js/React with TypeScript
- **Backend**: Modular Rails with API Gateway
- **Data**: PostgreSQL + pgvector, Redis, OpenSearch
- **Analytics**: S3 Data Lake, Snowflake/BigQuery, dbt

---

## Contributing

This repository serves as both a working codebase and strategic planning document. When contributing:

1. **Code Changes**: Follow cursor_rules guidelines
2. **Strategic Updates**: Update future-considerations documents
3. **Documentation**: Maintain knowledge-bases accuracy
4. **Architecture**: Align with V2 target architecture

---

## Contact

For questions about this repository or TPB's strategic direction, refer to the future-considerations documents or the appropriate knowledge-base sections.

---

*Last Updated: December 2024*
*Version: 1.0*
