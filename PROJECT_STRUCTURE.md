# TPB Future Project - Detailed Structure Guide

## Overview
This document provides a comprehensive breakdown of each folder and its contents within the TPB Future project, designed to help humans and AI agents quickly understand the project organization and locate relevant information.

---

## 📁 `cursor_rules/` - Development Guidelines & Standards

### Purpose
Contains Cursor IDE rules and development guidelines that ensure consistent code quality and patterns across all legacy repositories.

### Structure
```
cursor_rules/
├── api/rules/          # Rails backend guidelines (268 files)
├── cms/rules/          # Angular CMS guidelines (84 files)  
└── frontend/rules/     # Vue.js frontend guidelines (140 files)
```

### Key Contents
- **Code Quality Standards**: Naming conventions, formatting, and best practices
- **API Design Patterns**: RESTful design, error handling, versioning
- **Testing Guidelines**: Unit tests, integration tests, test coverage
- **Security Patterns**: Authentication, authorization, data protection
- **Performance Standards**: Caching, optimization, monitoring

### Usage
- Used by Cursor IDE for real-time code suggestions and validation
- Reference for developers working on legacy systems
- Foundation for V2 development standards

---

## 📁 `future-considerations/` - Strategic Planning & Roadmap

### Purpose
Strategic documents outlining TPB's transformation from legacy systems to AI agent-ready platform.

### Key Documents

#### `1_opening_reality_check_opportunity.md`
- **Core Thesis**: Retail transformation from search-and-browse to ask-and-delegate
- **Opportunity**: Position TPB as vertical intelligence layer for cannabis retail
- **Strategy**: Stabilize V1 while building V2 foundation

#### `3_strategy_stabilize_v_1_to_seed_v_2_not_wasted_work.md`
- **Approach**: Every V1 fix must reduce support burden AND become V2 building block
- **Focus Areas**: POS/CMS sync, API contracts, auth/security, observability
- **Timeline**: 30/60/90 day execution plan

#### `6_user_accounts_as_the_foundation.md`
- **Keystone**: User accounts as the V2 spine
- **Benefits**: Identity/consent layer, personalization, agent integration
- **Implementation**: Modern frontend with accounts, preferences, consent

#### `7_two_revenue_engines_in_parallel.md`
- **Engine A**: Affiliate/content feeds (outside cannabis) → near-term cash
- **Engine B**: Retail Data SaaS + Cannabis Agent API (inside cannabis) → scale
- **Strategy**: Diversified revenue while building cannabis moat

#### `8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`
- **Q1-Q2**: Stabilization and validation
- **Q3-Q4**: Productization and early scale
- **Year 2**: Scale and partner mode
- **Gates**: Success criteria for each quarter

#### `9_target_architecture_appendix.md`
- **V2 Architecture**: API Gateway, domain services, data layers
- **Agent-Ready**: Identity/consent, contracts, explainability
- **Tech Stack**: Next.js, Rails, PostgreSQL, Redis, OpenSearch

#### `11_ask_next_steps.md`
- **Immediate Actions**: Stabilization, frontend rebuild, data enrichment
- **Approvals Needed**: Leadership buy-in for strategic initiatives
- **Success Criteria**: Clear metrics and gates

---

## 📁 `knowledge-bases/` - AI-Generated Analysis & Documentation

### Purpose
Comprehensive LLM analysis of legacy systems, providing detailed documentation and migration guidance.

### Structure
```
knowledge-bases/
├── api-knowledge-base/           # Backend analysis
├── cms-knowledge-base/           # CMS analysis
├── front-end-knowledge-base/     # Frontend analysis
└── cross-repository-knowledge-base/  # Integration analysis
```

### `api-knowledge-base/` - Backend Analysis
**Purpose**: Complete documentation of the Rails backend API

**Key Sections**:
- **`api/`**: API endpoints, authentication, integration guides
- **`functional/`**: Feature-specific documentation (products, orders, users)
- **`system/`**: Architecture, data flow, domain models
- **`technical/`**: Implementation patterns, background jobs, caching
- **`database/`**: Schema documentation, migrations, relationships

**Notable Files**:
- `INDEX.md`: Central navigation for all documentation
- `current_and_next_steps.md`: Current status and next actions
- `next_steps_and_recommendations.md`: Strategic recommendations

### `cms-knowledge-base/` - CMS Analysis
**Purpose**: Comprehensive analysis of the Angular CMS application

**Key Sections**:
- **`implementation/patterns/`**: Core implementation patterns
- **`architecture/`**: System design and component relationships
- **`analysis/`**: Code quality, security, and performance analysis
- **`tracking/`**: Progress tracking and completion status

**Notable Files**:
- `README.md`: Master index with navigation guide
- `QUICK_REFERENCE.md`: Fast access to common information
- `HANDOFF.md`: Handover materials for future development

### `front-end-knowledge-base/` - Frontend Analysis
**Purpose**: Complete documentation of the Vue.js kiosk application

**Key Sections**:
- **`foundation/`**: Project setup, standards, environment
- **`system/`**: Technology stack, architecture, data flow
- **`functional/`**: Feature documentation (browsing, cart, checkout)
- **`technical/`**: Implementation details, state management, testing
- **`handover/`**: Migration guidance and future expansion

**Notable Files**:
- `index.md`: Comprehensive documentation index
- `navigation.md`: Role-based navigation guide
- `current_progress.md`: Current analysis status

### `cross-repository-knowledge-base/` - Integration Analysis
**Purpose**: Cross-repository analysis and migration planning

**Key Sections**:
- **`cross-repo/`**: Integration patterns and synthesis
- **`migration/`**: Migration strategy and timeline
- **`templates/`**: Analysis templates and standards

**Notable Files**:
- `analysis-index.md`: Central index for all analysis artifacts
- `cross-repo/executive-summary.md`: High-level findings
- `cross-repo/final-synthesis.md`: Comprehensive synthesis
- `migration/index.md`: Migration planning index

---

## 📁 `repositories/` - Legacy Code Repositories

### Purpose
The actual legacy code repositories that power TPB's current production systems.

### `back-end/` - Rails API
**Technology**: Ruby on Rails 6+ with PostgreSQL

**Key Features**:
- **Product Management**: Catalog, variants, pricing, inventory
- **POS Integrations**: Treez, Leaflogix, Shopify, Blaze, Covasoft, Headset
- **User Management**: Authentication, authorization, profiles
- **Order Processing**: Cart, checkout, payment processing
- **Analytics**: Event tracking, reporting, insights

**Architecture**:
- **Models**: 80+ ActiveRecord models for data management
- **Controllers**: RESTful API endpoints with versioning
- **Serializers**: JSON response formatting
- **Jobs**: Background processing with Sidekiq
- **Policies**: Authorization and access control

**Status**: Production system requiring stabilization and modernization

### `cms-fe-angular/` - Angular CMS
**Technology**: Angular 8 with TypeScript

**Key Features**:
- **Kiosk Management**: Layout configuration, asset management
- **Product Administration**: Catalog management, pricing, promotions
- **Store Configuration**: Settings, categories, tax management
- **User Management**: Client and user administration
- **Content Management**: Articles, banners, navigation

**Architecture**:
- **Components**: Modular UI components
- **Services**: Business logic and API integration
- **Modules**: Feature-based organization
- **Routing**: Single-page application navigation

**Status**: Legacy system, new features should target modern Admin UI

### `front-end/` - Vue.js Kiosk
**Technology**: Vue.js 2 with JavaScript

**Key Features**:
- **Product Browsing**: Search, filters, categories, recommendations
- **Shopping Experience**: Cart, checkout, payment processing
- **Offline Support**: Local storage, sync capabilities
- **Analytics**: User behavior tracking, conversion metrics
- **Responsive Design**: Touch-optimized for kiosk displays

**Architecture**:
- **Components**: Reusable UI components
- **Store**: Vuex state management
- **Router**: Client-side navigation
- **Mixins**: Shared functionality
- **API**: HTTP client for backend communication

**Status**: Legacy system, target for React migration

---

## 📁 `TPB-Ecomm-FE-and-BE/` - Modern E-commerce Extension

### Purpose
Unfinished side project demonstrating modern architecture with user accounts and e-commerce capabilities. Serves as reference implementation for V2 development.

### `ThePeakBeyond_eCommerce/` - React Frontend
**Technology**: React with TypeScript, Redux Toolkit

**Key Features**:
- **User Authentication**: Login, registration, profile management
- **Product Browsing**: Search, filters, favorites, recommendations
- **Shopping Cart**: Add/remove items, quantity management
- **Order Management**: Purchase history, order tracking
- **Dashboard**: User preferences, account settings

**Architecture**:
- **Components**: Functional components with hooks
- **State Management**: Redux Toolkit for global state
- **Routing**: React Router for navigation
- **Styling**: SCSS with component-scoped styles
- **API Integration**: HTTP client with TypeScript interfaces

**Status**: Incomplete but valuable for V2 reference

### `ThePeakBeyond_eCommerce_API/` - NestJS Backend
**Technology**: NestJS with TypeScript

**Key Features**:
- **RESTful API**: RESTful endpoints with OpenAPI documentation
- **Authentication**: JWT-based auth with refresh tokens
- **Database Integration**: TypeORM with PostgreSQL
- **Module Architecture**: Feature-based module organization
- **Validation**: DTOs with class-validator

**Architecture**:
- **Modules**: Feature-based organization (brand, product, store, etc.)
- **Controllers**: Request handling and response formatting
- **Services**: Business logic and data access
- **Providers**: External service integration
- **Guards**: Authentication and authorization

**Status**: Incomplete but demonstrates modern patterns

---

## Navigation Guide

### For New Team Members
1. **Start Here**: Read the main `README.md` for project overview
2. **Strategic Context**: Review `future-considerations/` for business direction
3. **System Understanding**: Explore `knowledge-bases/` for technical details
4. **Code Reference**: Examine `repositories/` for current implementation
5. **Modern Patterns**: Study `TPB-Ecomm-FE-and-BE/` for V2 reference

### For Developers
1. **Legacy Development**: Use `cursor_rules/` for coding standards
2. **System Analysis**: Reference `knowledge-bases/` for comprehensive documentation
3. **Migration Planning**: Follow `cross-repository-knowledge-base/` for integration guidance
4. **V2 Development**: Use `TPB-Ecomm-FE-and-BE/` as architecture reference

### For AI Agents
1. **System Understanding**: Start with `cross-repository-knowledge-base/`
2. **Code Analysis**: Use individual knowledge bases for specific repositories
3. **Strategic Context**: Review `future-considerations/` for business objectives
4. **Development**: Follow `cursor_rules/` for code generation and modification

### For Strategic Planning
1. **Current State**: Review `knowledge-bases/` for system understanding
2. **Future Direction**: Study `future-considerations/` for strategic roadmap
3. **Implementation**: Use `TPB-Ecomm-FE-and-BE/` as V2 architecture reference
4. **Execution**: Follow quarterly roadmap in `future-considerations/`

---

## Key Relationships

### Strategic Flow
```
future-considerations/ → Strategic Direction
         ↓
knowledge-bases/ → System Understanding
         ↓
repositories/ → Current Implementation
         ↓
TPB-Ecomm-FE-and-BE/ → V2 Reference
```

### Development Flow
```
cursor_rules/ → Development Standards
         ↓
knowledge-bases/ → Technical Documentation
         ↓
repositories/ → Legacy Code
         ↓
TPB-Ecomm-FE-and-BE/ → Modern Patterns
```

### Analysis Flow
```
repositories/ → Source Code
         ↓
knowledge-bases/ → AI Analysis
         ↓
future-considerations/ → Strategic Planning
```

---

*This document provides a comprehensive guide to navigating the TPB Future project. For specific technical details, refer to the individual knowledge bases and strategic documents.*
