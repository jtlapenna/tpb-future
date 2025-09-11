# TPB Future Implementation Roadmap

## Overview
This roadmap synthesizes findings from V1 analysis, e-commerce analysis, and portability assessment to create a comprehensive implementation plan aligned with the strategic goals outlined in `../future-considerations/`.

## Strategic Context
Based on future-considerations analysis, our implementation must support:
- **V1 Stabilization** → V2 Spine development
- **Dual Revenue Engines** (Affiliate feeds + Data SaaS)
- **Agent Economy Positioning** (Vertical intelligence layer)
- **User Accounts as Foundation** (Identity, consent, personalization)

## Implementation Phases

### Phase 1: Foundation & Stabilization (Months 1-3)
**Objective**: Stabilize V1 systems while beginning V2 spine assembly

#### V1 Stabilization Tasks
- [ ] **POS/CMS Sync Reliability** (Highest ROI)
  - Implement circuit breakers and exponential backoff
  - Add idempotent writes with retry policies
  - Create poison queue with operator reprocess tools
  - Add structured logging with correlation IDs
  - **V2 Payoff**: Becomes V2 ingestion service

- [ ] **API Contracts & Error Handling**
  - Publish shared error code registry
  - Standardize JSON error envelopes
  - Add integration tests for outage simulation
  - **V2 Payoff**: Becomes partner/public API foundation

- [ ] **Auth & Security Hygiene**
  - Move to short-lived access + refresh tokens
  - Implement HTTP-only secure cookies
  - Draft consent scopes for agent access
  - **V2 Payoff**: Establishes identity/consent model

- [ ] **Observability & CI/CD**
  - Remove manual SSH steps
  - Add dependency audits and security scans
  - Implement end-to-end tracing
  - **V2 Payoff**: Provides reliability substrate

#### V2 Spine Assembly
- [ ] **Frontend Modernization** (AI-Assisted)
  - Complete Vue.js → React 18 migration
  - Integrate TPB-Ecomm-FE-and-BE user accounts
  - Modern component library and state management
  - **Timeline**: 12 weeks (750-1000 hours)
  - **Team**: 3-4 developers
  - **Budget**: $75k-100k

- [ ] **User Accounts Integration**
  - AWS Cognito authentication
  - Profile management with custom attributes
  - In-store pairing flow (QR/passkey)
  - **Timeline**: 4-6 weeks (integrated with frontend)

- [ ] **Data Enrichment (Products Domain)**
  - Extend schema for terpenes/effects/lab results
  - Update importers and CMS write paths
  - Add validation scripts and backfill plan
  - **V2 Payoff**: Fuels personalization and Agent API

#### Success Metrics
- Sync success rate ≥ 99% daily
- Support hours ↓ 25%
- 40% of active SKUs with effects populated
- User accounts MVP deployed

### Phase 2: Modern Frontend & Data Platform (Months 4-6)
**Objective**: Complete V2 spine with modern frontend and enriched data platform

#### Frontend Development
- [ ] **Admin UI (Products Domain)**
  - Replace Angular CMS with modern admin interface
  - Products domain MVP with new attributes
  - Role-based access and audit trail
  - **Timeline**: 4-6 weeks
  - **Leverage**: Modern React components from frontend modernization

- [ ] **Personalization Features**
  - Effects-aware recommendations
  - Budget-aware suggestions
  - Safer alternatives display
  - **Timeline**: 6-8 weeks

#### Data Platform
- [ ] **Brand/Lab Feed Integration**
  - Onboard first COA sources
  - Implement provenance tracking
  - Backfill high-velocity SKUs
  - **Timeline**: 4-6 weeks

- [ ] **API v1.1 Endpoints**
  - Catalog endpoints with new attributes
  - Availability and compliance APIs
  - Webhook events (inventory.updated, price.changed)
  - **Timeline**: 6-8 weeks

#### Success Metrics
- 60% of active SKUs with effects
- 25% of in-store sessions attempt pairing
- 3 stores using dashboards weekly
- Admin UI replaces CMS for products

### Phase 3: Revenue Engine Development (Months 7-12)
**Objective**: Launch dual revenue engines while maintaining V2 development

#### Engine A: Affiliate Feeds (Outside Cannabis)
- [ ] **Content System Enhancement**
  - Scale from 4 → 7 affiliate sites
  - Enforce HTML + JSON output per post
  - Standardize feed schemas (schema.org/Product)
  - **Timeline**: 8-10 weeks

- [ ] **Developer Portal**
  - Feed access keys and documentation
  - Usage tiers and billing
  - API sandbox for testing
  - **Timeline**: 6-8 weeks

#### Engine B: Data SaaS (Inside Cannabis)
- [ ] **Retail Data Dashboard v2**
  - Effects-aware analytics
  - Campaign management tools
  - Attribution tracking (agent vs human)
  - **Timeline**: 8-10 weeks

- [ ] **Cannabis Agent API Alpha**
  - Effects-based recommendations
  - Compliance and availability queries
  - Partner sandbox and SDK
  - **Timeline**: 10-12 weeks

#### Success Metrics
- 7 affiliate sites live with JSON feeds
- 5 stores using dashboards
- First feed licensing deals signed
- Agent API prototype with 2 partners

### Phase 4: Scale & Partner Mode (Months 13-18)
**Objective**: Scale both revenue engines and establish market position

#### Platform Scaling
- [ ] **Multi-tenant Architecture**
  - Harden infrastructure for scale
  - Rate limits and API analytics
  - Public status page
  - **Timeline**: 6-8 weeks

- [ ] **Advanced Features**
  - Recommender v2 with feedback learning
  - Deeper personalization (location, time, tolerance)
  - Campaign experiments and A/B testing
  - **Timeline**: 8-10 weeks

#### Revenue Engine Scaling
- [ ] **Engine A Expansion**
  - 10+ feed licensees across niches
  - Premium curation and sponsorships
  - White-label microfeeds for retailers
  - **Timeline**: 10-12 weeks

- [ ] **Engine B Expansion**
  - Agent API paid plans
  - Partner marketplace
  - Reference integrations
  - **Timeline**: 12-14 weeks

#### Success Metrics
- 30-40 stores on dashboards
- 10-20 paying API partners
- 1M+ monthly API calls
- $15k-30k/month from Engine A

## Technical Implementation Strategy

### AI-Assisted Development Approach
**Frontend Modernization (Phase 1)**:
- **AI Tools**: Cursor, GitHub Copilot, React Codemod, automated testing
- **Time Savings**: 30-40% vs. human-only development
- **Total Effort**: 750-1000 hours (vs. 1000-1400 hours human-only)
- **Cost Savings**: $25k-40k vs. human-only approach

**Resource Comparison**:
| Approach | Hours | Cost | Time Savings |
|----------|-------|------|--------------|
| **AI-Assisted (with TPB-Ecomm-FE-and-BE)** | 750-1000 | $75k-100k | 50-60% |
| **Human-Only (with TPB-Ecomm-FE-and-BE)** | 1000-1400 | $100k-140k | 30-40% |
| **From Scratch (AI-Assisted)** | 1200-1800 | $120k-180k | 0% |
| **From Scratch (Human-Only)** | 1800-2400 | $180k-240k | 0% |

### Architecture Approach
- **Strangler Pattern**: Gradually replace V1 components with V2
- **Domain-First Migration**: Products → Orders → Promotions
- **API Gateway**: Single entry point with OpenAPI/AsyncAPI contracts
- **Event-Driven**: Async processing with webhooks and event bus

### Technology Stack
- **Frontend**: Next.js/React + TypeScript
- **Backend**: Rails (V1) + NestJS (V2 APIs)
- **Database**: Postgres + Redis + OpenSearch
- **Analytics**: dbt + Snowflake/BigQuery
- **Infrastructure**: AWS with containerization

### Code Reuse Strategy
- **Component Library**: Shared UI components across admin and shopper apps
- **API Patterns**: Reuse authentication, validation, and error handling
- **State Management**: Redux Toolkit patterns for complex state
- **Testing**: Jest and React Testing Library patterns

## Risk Mitigation

### Technical Risks
- **V1 Stability**: Maintain parallel systems during migration
- **Data Quality**: Implement contracts and validation at ingest
- **Performance**: Load testing and monitoring for scale
- **Security**: Automated security scanning and secret rotation

### Business Risks
- **Customer Churn**: Maintain feature parity during transition
- **Resource Constraints**: Prioritize highest-impact activities
- **Market Timing**: Build agent-ready features for future demand
- **Competition**: Focus on data moat and vertical expertise

## Resource Requirements

### Development Team

#### Phase 1: Frontend Modernization (Months 1-3)
- **Frontend Lead Developer**: React 18, TypeScript, Next.js expertise
- **Frontend Developer (Mid-level)**: React, component development, testing
- **UI/UX Developer**: Material-UI, Tailwind CSS, responsive design
- **Backend Developer**: Rails + API integration support
- **Total Team**: 4 developers
- **Budget**: $75k-100k

#### Phase 2+: Full Platform Development (Months 4-18)
- **Frontend Developer**: Next.js/React expertise (from Phase 1)
- **Backend Developer**: Rails + NestJS experience
- **Data Engineer**: dbt + analytics platform
- **DevOps Engineer**: AWS + containerization
- **Product Manager**: Strategic alignment and prioritization
- **Total Team**: 5 developers

### Infrastructure
- **Development Environment**: Containerized local development
- **Staging Environment**: Production-like testing environment
- **Production Environment**: Multi-tenant scalable infrastructure
- **Monitoring**: Comprehensive observability and alerting

## Success Metrics & KPIs

### Technical Metrics
- Sync success rate ≥ 99% daily
- API response time ≤ 200ms p95
- Uptime ≥ 99.9%
- Test coverage ≥ 80%

### Business Metrics
- User account adoption rate
- Personalization uplift (AOV +8-12%)
- Revenue growth (Engine A + Engine B)
- Partner satisfaction (NPS ≥ +20)

### Strategic Metrics
- Agent-assisted conversion tracking
- Data quality (dbt test pass ≥ 90%)
- API usage growth
- Market positioning strength

## Next Steps

### Immediate Actions (Next 30 Days)
1. **Begin V1 Stabilization** - Start with POS/CMS sync reliability
2. **Assemble Frontend Team** - Hire/assign 3-4 developers for modernization
3. **Set up Development Environment** - Next.js 14 + TypeScript + AI tools
4. **Create Project Management** - Jira/Linear with epics and stories
5. **Stakeholder Alignment** - Confirm $75k-100k budget for frontend modernization

### Short-term Actions (Next 90 Days)
1. **Complete V1 Stabilization** - All high-priority fixes implemented
2. **Complete Frontend Modernization** - Vue.js → React 18 + user accounts
3. **Launch User Accounts MVP** - Basic authentication and preferences
4. **Begin Data Enrichment** - Terpenes and effects schema extension
5. **Start Admin UI Development** - Products domain replacement

### Long-term Actions (Next 6-12 Months)
1. **Launch Revenue Engines** - Both Engine A and Engine B operational
2. **Scale Platform** - Multi-tenant architecture and advanced features
3. **Establish Market Position** - Partner network and API ecosystem
4. **Prepare for Agent Economy** - Full agent-ready platform

---

*This roadmap provides a comprehensive implementation plan that balances immediate needs (V1 stabilization) with long-term strategic goals (agent economy positioning) while maintaining focus on the dual revenue engine strategy.*
