# Documentation Content Map

## Meta Documentation

### Planning
1. documentation_plan.md
   - Category: Meta Documentation
   - Type: Plan/Strategy
   - Status: Current
   - Last Updated: Mar 12, 05:29 PM
   - Related: reorganization_implementation_plan.md, consolidation_plan.md

2. reorganization_implementation_plan.md
   - Category: Meta Documentation
   - Type: Plan/Strategy
   - Status: Current
   - Last Updated: Mar 14, 04:15 AM
   - Related: documentation_plan.md, consolidation_plan.md

### Progress Tracking
1. reorganization_progress.md
   - Category: Meta Documentation
   - Type: Progress Report
   - Status: Current
   - Last Updated: Mar 14, 04:20 AM
   - Related: audit_progress.md, file_inventory.md

2. file_inventory.md
   - Category: Meta Documentation
   - Type: Reference Guide
   - Status: Current
   - Last Updated: Mar 14, 04:20 AM
   - Related: reorganization_progress.md

### Guidelines and Standards
1. ai_agent_documentation_rules.md
   - Category: Meta Documentation
   - Type: Reference Guide
   - Status: Current
   - Last Updated: Mar 11, 10:36 PM
   - Related: contributor_guidelines.md, metadata_standards.md

2. metadata_standards.md
   - Category: Meta Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 11, 10:33 PM
   - Related: ai_agent_documentation_rules.md

## API Documentation

### Core API
1. api_documentation_summary.md
   - Category: API Documentation
   - Type: Overview/Summary
   - Status: Current
   - Last Updated: Mar 12, 02:48 PM
   - Related: api_controllers_and_endpoints.md, api_reference.md
   - Keywords: architecture, patterns, integration, endpoints

2. api_controllers_and_endpoints.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:00 PM
   - Related: controller_actions.md, api_documentation_summary.md
   - Keywords: controllers, endpoints, implementation

3. controller_actions.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 14, 04:31 AM
   - Related: api_controllers_and_endpoints.md
   - Keywords: controllers, actions, routing

### Integration
1. backend_frontend_integration_summary.md
   - Category: API Documentation
   - Type: Overview/Summary
   - Status: Current
   - Last Updated: Mar 12, 03:09 PM
   - Related: api_integration_patterns.md, real_time_communication.md
   - Keywords: frontend, integration, patterns

2. real_time_communication.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:07 PM
   - Related: backend_frontend_integration_summary.md
   - Keywords: real-time, websockets, communication

3. serializers_overview.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:05 PM
   - Related: api_controllers_and_endpoints.md
   - Keywords: serializers, data formatting, responses

### Security
1. authorization_mechanisms.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:04 PM
   - Related: authentication_mechanisms.md, authentication_and_authorization.md
   - Keywords: authorization, permissions, security

2. authentication_mechanisms.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:03 PM
   - Related: authorization_mechanisms.md, authentication_and_authorization.md
   - Keywords: authentication, security, jwt

3. authentication_and_authorization.md
   - Category: API Documentation
   - Type: Overview/Summary
   - Status: Current
   - Last Updated: Mar 11, 11:01 PM
   - Related: authentication_mechanisms.md, authorization_mechanisms.md
   - Keywords: security, authentication, authorization

### Administrative Endpoints

#### Store Management
1. create_store_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 11, 11:03 PM
   - Related: update_store_endpoint.md, list_stores_endpoint.md
   - Keywords: store, creation, endpoint

2. update_store_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 11, 11:08 PM
   - Related: create_store_endpoint.md, get_store_endpoint.md
   - Keywords: store, update, endpoint

3. list_stores_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 11, 11:10 PM
   - Related: get_store_endpoint.md, create_store_endpoint.md
   - Keywords: store, list, endpoint

4. get_store_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 11, 11:12 PM
   - Related: list_stores_endpoint.md, update_store_endpoint.md
   - Keywords: store, retrieval, endpoint

5. generate_store_token_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:52 AM
   - Related: create_store_endpoint.md, authentication_mechanisms.md
   - Keywords: store, token, authentication

#### Kiosk Management
1. create_kiosk_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: update_kiosk_endpoint.md, list_kiosks_endpoint.md
   - Keywords: kiosk, creation, endpoint

2. update_kiosk_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: create_kiosk_endpoint.md, get_kiosk_endpoint.md
   - Keywords: kiosk, update, endpoint

3. list_kiosks_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: create_kiosk_endpoint.md, clone_kiosk_endpoint.md
   - Keywords: kiosk, list, endpoint

4. clone_kiosk_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: create_kiosk_endpoint.md, update_kiosk_endpoint.md
   - Keywords: kiosk, clone, configuration

#### Product Management
1. create_product_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: update_product_endpoint.md, list_products_endpoint.md
   - Keywords: product, creation, endpoint

2. update_product_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: create_product_endpoint.md, get_product_endpoint.md
   - Keywords: product, update, endpoint

3. list_products_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: get_product_endpoint.md, search_products_endpoint.md
   - Keywords: product, list, endpoint

4. get_product_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: list_products_endpoint.md, update_product_endpoint.md
   - Keywords: product, retrieval, endpoint

5. search_products_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:48 PM
   - Related: list_products_endpoint.md, get_product_endpoint.md
   - Keywords: product, search, filtering

#### Order Management
1. create_order_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:54 PM
   - Related: update_order_endpoint.md, list_orders_endpoint.md
   - Keywords: order, creation, endpoint

2. update_order_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 01:56 PM
   - Related: create_order_endpoint.md, get_order_endpoint.md
   - Keywords: order, update, endpoint

3. list_orders_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:04 PM
   - Related: get_order_endpoint.md, create_order_endpoint.md
   - Keywords: order, list, endpoint

4. get_order_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:06 PM
   - Related: list_orders_endpoint.md, update_order_endpoint.md
   - Keywords: order, retrieval, endpoint

#### Customer Management
1. create_customer_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:16 PM
   - Related: update_customer_endpoint.md, list_customers_endpoint.md
   - Keywords: customer, creation, endpoint

2. list_customers_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:15 PM
   - Related: get_customer_endpoint.md, create_customer_endpoint.md
   - Keywords: customer, list, endpoint

3. update_customer_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:17 PM
   - Related: create_customer_endpoint.md, get_customer_endpoint.md
   - Keywords: customer, update, endpoint

4. get_customer_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:18 PM
   - Related: list_customers_endpoint.md, update_customer_endpoint.md
   - Keywords: customer, retrieval, endpoint

#### User Management
1. list_users_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:31 PM
   - Related: create_user_endpoint.md, get_user_endpoint.md
   - Keywords: user, list, endpoint

2. create_user_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:31 PM
   - Related: update_user_endpoint.md, list_users_endpoint.md
   - Keywords: user, creation, endpoint

3. get_user_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:32 PM
   - Related: list_users_endpoint.md, current_user_endpoint.md
   - Keywords: user, retrieval, endpoint

4. update_user_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:32 PM
   - Related: create_user_endpoint.md, get_user_endpoint.md
   - Keywords: user, update, endpoint

5. current_user_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:42 PM
   - Related: get_user_endpoint.md, user_endpoints_summary.md
   - Keywords: user, current, session

6. user_endpoints_summary.md
   - Category: API Documentation
   - Type: Overview/Summary
   - Status: Current
   - Last Updated: Mar 12, 02:46 PM
   - Related: current_user_endpoint.md, list_users_endpoint.md
   - Keywords: user, endpoints, summary

#### Other Administrative Endpoints
1. get_inventory_data_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 03:01 AM
   - Related: list_products_endpoint.md
   - Keywords: inventory, data, retrieval

2. tax_customer_types_endpoint.md
   - Category: API Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 12, 02:58 AM
   - Related: create_customer_endpoint.md
   - Keywords: tax, customer, types

## Frontend Documentation

#### Architecture and Planning
1. frontend_architecture_overview.md
   - Category: Frontend Documentation
   - Type: Technical Architecture
   - Status: Current
   - Last Updated: Mar 12, 03:13 PM
   - Related: state_management_approach.md, api_integration_patterns.md
   - Keywords: architecture, structure, patterns

2. frontend_documentation_plan.md
   - Category: Frontend Documentation
   - Type: Planning Document
   - Status: Current
   - Last Updated: Mar 12, 03:10 PM
   - Related: frontend_documentation_progress.md
   - Keywords: planning, documentation, roadmap

3. frontend_documentation_progress.md
   - Category: Frontend Documentation
   - Type: Progress Report
   - Status: Current
   - Last Updated: Mar 12, 04:21 PM
   - Related: frontend_documentation_plan.md
   - Keywords: progress, tracking, status

4. frontend_documentation_summary.md
   - Category: Frontend Documentation
   - Type: Overview/Summary
   - Status: Current
   - Last Updated: Mar 12, 03:18 PM
   - Related: frontend_architecture_overview.md
   - Keywords: summary, overview, documentation

#### Implementation Details
1. state_management_approach.md
   - Category: Frontend Documentation
   - Type: Technical Implementation
   - Status: Current
   - Last Updated: Mar 12, 03:17 PM
   - Related: frontend_architecture_overview.md, api_integration_patterns.md
   - Keywords: state management, data flow, architecture

2. api_integration_patterns.md
   - Category: Frontend Documentation
   - Type: Technical Implementation
   - Status: Current
   - Last Updated: Mar 12, 03:15 PM
   - Related: state_management_approach.md
   - Keywords: api, integration, patterns

#### User Flows
1. kiosk_user_flows.md
   - Category: Frontend Documentation
   - Type: User Flow Documentation
   - Status: Current
   - Last Updated: Mar 12, 03:14 PM
   - Related: cms_user_flows_implementation_plan.md
   - Keywords: kiosk, user flows, interaction

2. cms_user_flows_implementation_plan.md
   - Category: Frontend Documentation
   - Type: Implementation Plan
   - Status: Current
   - Last Updated: Mar 12, 03:22 PM
   - Related: kiosk_user_flows.md
   - Keywords: cms, user flows, implementation

#### Components
1. product_card.md
   - Category: Frontend Documentation
   - Type: Component Documentation
   - Status: Current
   - Last Updated: Mar 12, 03:25 PM
   - Related: api_integration_patterns.md
   - Keywords: component, product, ui

## System Documentation

#### Domain Model
1. multi_tenant_architecture.md
   - Category: System Documentation
   - Type: Architecture Documentation
   - Status: Current
   - Last Updated: Mar 11, 10:35 PM
   - Related: current_architecture_analysis.md
   - Keywords: multi-tenant, architecture, domain

#### System Overview
1. README.md
   - Category: System Documentation
   - Type: Overview Document
   - Status: Current
   - Last Updated: Mar 11, 10:30 PM
   - Related: multi_tenant_architecture.md
   - Keywords: overview, system, documentation

#### Modernization
1. next_steps.md
   - Category: System Documentation
   - Type: Planning Document
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: rebuilding_insights_steps.md
   - Keywords: modernization, planning, next steps

##### Executive Summary
1. rebuilding_insights_summary.md
   - Category: System Documentation
   - Type: Executive Summary
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: modernization_recommendations.md
   - Keywords: modernization, summary, insights

##### Main Documentation
1. current_architecture_analysis.md
   - Category: System Documentation
   - Type: Analysis Document
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: multi_tenant_architecture.md, modernization_opportunities.md
   - Keywords: architecture, analysis, current state

2. modernization_opportunities.md
   - Category: System Documentation
   - Type: Analysis Document
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: current_architecture_analysis.md, modernization_recommendations.md
   - Keywords: modernization, opportunities, analysis

3. modernization_recommendations.md
   - Category: System Documentation
   - Type: Recommendations
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: modernization_opportunities.md, rebuilding_insights_summary.md
   - Keywords: modernization, recommendations, strategy

##### Review Documentation
1. rebuilding_insights_checklist.md
   - Category: System Documentation
   - Type: Checklist
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: rebuilding_insights_verification.md
   - Keywords: modernization, checklist, verification

2. rebuilding_insights_verification.md
   - Category: System Documentation
   - Type: Verification Document
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: rebuilding_insights_checklist.md
   - Keywords: modernization, verification, validation

##### Progress Documentation
1. rebuilding_insights_progress.md
   - Category: System Documentation
   - Type: Progress Report
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: rebuilding_insights_steps.md
   - Keywords: modernization, progress, tracking

2. rebuilding_insights_steps.md
   - Category: System Documentation
   - Type: Implementation Plan
   - Status: Current
   - Last Updated: Mar 12, 10:43 PM
   - Related: rebuilding_insights_progress.md, next_steps.md
   - Keywords: modernization, steps, implementation

## Configuration Documentation

#### Requirements
1. configuration_requirements.md
   - Category: Configuration Documentation
   - Type: Technical Specification
   - Status: Current
   - Last Updated: Mar 14, 04:52 AM
   - Related: multi_tenant_architecture.md
   - Keywords: configuration, requirements, setup

## Next Steps
1. Begin version analysis preparation
2. Review and validate all categorization
3. Create comprehensive relationship diagrams
4. Document content gaps and recommendations

*Created: March 20, 2024*
*Last Updated: March 20, 2024* 