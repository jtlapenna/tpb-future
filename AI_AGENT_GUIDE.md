# AI Agent Quick Reference Guide

## Project Overview
The Peak Beyond (TPB) Future project contains legacy cannabis retail systems, strategic planning documents, and modern e-commerce extensions. The goal is to stabilize legacy systems while building V2 foundation for AI agent economy integration.

## Quick Navigation

### 🎯 **Start Here for System Understanding**
- **`knowledge-bases/cross-repository-knowledge-base/`** - Complete system analysis
- **`future-considerations/1_opening_reality_check_opportunity.md`** - Strategic context
- **`future-considerations/9_target_architecture_appendix.md`** - V2 target architecture

### 🔧 **For Code Development**
- **`cursor_rules/`** - Development standards and patterns
- **`repositories/`** - Legacy code repositories
- **`TPB-Ecomm-FE-and-BE/`** - Modern reference implementations

### 📊 **For Strategic Planning**
- **`future-considerations/8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`** - Detailed roadmap
- **`future-considerations/11_ask_next_steps.md`** - Immediate action items

## Repository Quick Reference

| Repository | Technology | Purpose | Status |
|------------|------------|---------|---------|
| `back-end/` | Rails + PostgreSQL | Core API | Production (needs stabilization) |
| `cms-fe-angular/` | Angular 8 | Content Management | Legacy (freeze new features) |
| `front-end/` | Vue.js 2 | Kiosk Displays | Legacy (target for React migration) |
| `TPB-Ecomm-FE-and-BE/` | React + NestJS | Modern E-commerce | Incomplete (V2 reference) |

## Key Strategic Concepts

### V1 Stabilization Strategy
- **Principle**: Every V1 fix must reduce support burden AND become V2 building block
- **Focus**: POS/CMS sync, API contracts, auth/security, observability
- **Timeline**: 30/60/90 day execution plan

### V2 Foundation
- **Keystone**: User accounts as the spine
- **Architecture**: API Gateway + domain services + agent-ready contracts
- **Goal**: Position as vertical intelligence layer for cannabis retail

### Dual Revenue Engines
- **Engine A**: Affiliate/content feeds (outside cannabis) → near-term cash
- **Engine B**: Retail Data SaaS + Cannabis Agent API (inside cannabis) → scale

## Common Tasks & Where to Look

### Understanding Current System
1. **`knowledge-bases/cross-repository-knowledge-base/executive-summary.md`** - High-level overview
2. **`knowledge-bases/[repo-name]/README.md`** - Repository-specific details
3. **`repositories/[repo-name]/README.md`** - Basic setup and usage

### Planning V2 Development
1. **`future-considerations/9_target_architecture_appendix.md`** - Target architecture
2. **`TPB-Ecomm-FE-and-BE/`** - Modern implementation patterns
3. **`future-considerations/3_strategy_stabilize_v_1_to_seed_v_2_not_wasted_work.md`** - Migration strategy

### Code Quality & Standards
1. **`cursor_rules/[repo-name]/rules/`** - Development guidelines
2. **`knowledge-bases/[repo-name]/technical/`** - Implementation patterns
3. **`knowledge-bases/[repo-name]/system/`** - Architecture guidelines

### Strategic Context
1. **`future-considerations/1_opening_reality_check_opportunity.md`** - Business thesis
2. **`future-considerations/8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`** - Execution plan
3. **`future-considerations/11_ask_next_steps.md`** - Immediate priorities

## Key Files to Bookmark

### Strategic Documents
- `future-considerations/1_opening_reality_check_opportunity.md` - Core business thesis
- `future-considerations/3_strategy_stabilize_v_1_to_seed_v_2_not_wasted_work.md` - V1→V2 strategy
- `future-considerations/8_12_24_month_hybrid_roadmap_quarter_by_quarter.md` - Detailed roadmap
- `future-considerations/9_target_architecture_appendix.md` - V2 architecture

### Technical References
- `knowledge-bases/cross-repository-knowledge-base/executive-summary.md` - System overview
- `knowledge-bases/cross-repository-knowledge-base/final-synthesis.md` - Complete analysis
- `cursor_rules/api/rules/_repository.mdc` - Backend development rules
- `cursor_rules/frontend/rules/_repository.mdc` - Frontend development rules

### Implementation Examples
- `TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce/src/` - Modern React patterns
- `TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API/src/` - Modern API patterns
- `repositories/back-end/app/` - Legacy Rails patterns
- `repositories/front-end/src/` - Legacy Vue.js patterns

## Development Workflow

### For Legacy System Maintenance
1. **Read**: `cursor_rules/[repo]/rules/` for standards
2. **Understand**: `knowledge-bases/[repo]/` for context
3. **Code**: Follow established patterns in `repositories/[repo]/`
4. **Test**: Use patterns from `knowledge-bases/[repo]/technical/testing/`

### For V2 Development
1. **Plan**: Review `future-considerations/9_target_architecture_appendix.md`
2. **Reference**: Study `TPB-Ecomm-FE-and-BE/` for modern patterns
3. **Standards**: Follow `cursor_rules/` guidelines
4. **Integrate**: Use `knowledge-bases/cross-repository-knowledge-base/` for system understanding

### For Strategic Analysis
1. **Context**: Start with `future-considerations/1_opening_reality_check_opportunity.md`
2. **Current State**: Review `knowledge-bases/cross-repository-knowledge-base/`
3. **Future Vision**: Study `future-considerations/8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`
4. **Implementation**: Reference `TPB-Ecomm-FE-and-BE/` for modern patterns

## Common Patterns

### API Development
- **Legacy**: Rails controllers with serializers (`repositories/back-end/app/`)
- **Modern**: NestJS modules with DTOs (`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API/src/`)
- **Standards**: RESTful design with versioning (`cursor_rules/api/rules/`)

### Frontend Development
- **Legacy**: Vue.js components with Vuex (`repositories/front-end/src/`)
- **Modern**: React components with Redux (`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce/src/`)
- **Standards**: Component-based architecture (`cursor_rules/frontend/rules/`)

### Data Management
- **Legacy**: ActiveRecord models (`repositories/back-end/app/models/`)
- **Modern**: TypeORM entities (`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API/src/models/`)
- **Patterns**: Repository pattern, service layer (`knowledge-bases/api-knowledge-base/`)

## Success Metrics

### V1 Stabilization
- Sync success rate ≥ 99% daily
- Support hours reduction by 25%
- Mean time to recovery (MTTR) improvement

### V2 Development
- User account adoption and personalization uplift
- API partner adoption and revenue growth
- Agent-ready data feeds and contracts

### Strategic Goals
- Position as vertical intelligence layer for cannabis retail
- Dual revenue streams (affiliate + data SaaS)
- AI agent economy integration

## Emergency Contacts

### For Technical Issues
- **Legacy Systems**: Check `knowledge-bases/[repo]/troubleshooting/`
- **Architecture Questions**: Review `knowledge-bases/cross-repository-knowledge-base/`
- **Development Standards**: Consult `cursor_rules/[repo]/rules/`

### For Strategic Questions
- **Business Context**: Read `future-considerations/1_opening_reality_check_opportunity.md`
- **Roadmap**: Check `future-considerations/8_12_24_month_hybrid_roadmap_quarter_by_quarter.md`
- **Next Steps**: Review `future-considerations/11_ask_next_steps.md`

---

*This guide provides quick access to the most important information for AI agents working with the TPB Future project. For detailed technical information, refer to the specific knowledge bases and strategic documents.*
