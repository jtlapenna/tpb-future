# AI Agent Quick Reference Guide

## 🎯 **PROJECT STATUS: ACTIVE DEVELOPMENT**

**Current Phase**: V2 Foundation Development  
**Primary Focus**: E-commerce project modernization  
**Decision Made**: Using TPB-Ecomm-FE-and-BE as foundation  
**Next Milestone**: Complete e-commerce modernization (3 months)  

## Project Overview
The Peak Beyond (TPB) Future project contains legacy cannabis retail systems, strategic planning documents, and modern e-commerce extensions. **We have made a strategic decision to use the TPB-Ecomm-FE-and-BE project as our foundation for V2 development**, rather than rebuilding from legacy systems.

## Quick Navigation

### 🎯 **Start Here for Current Project Status**
- **`PROJECT_STATUS.md`** - Current project state and decisions
- **`DEVELOPER_ONBOARDING.md`** - Guide for new developers
- **`analysis-workflow/OVERVIEW.md`** - Strategic decision and analysis overview

### 🚀 **Primary Development Focus**
- **`TPB-Ecomm-FE-and-BE/`** - **YOUR MAIN TARGET** - E-commerce modernization
- **`TPB-Ecomm-FE-and-BE/SETUP_GUIDE.md`** - How to run the project
- **`TPB-Ecomm-FE-and-BE/LOCAL_DEVELOPMENT.md`** - Development setup

### ⚠️ **Maintenance Only (Don't Focus Here)**
- **`repositories/`** - Legacy systems (maintain for production only)
- **`modern-frontend/`** - Colleague's experiment (ignore completely)

### 📊 **For Strategic Context**
- **`future-considerations/`** - Strategic business objectives
- **`analysis-workflow/`** - Technical analysis and decisions

## Repository Quick Reference

| Repository | Technology | Purpose | Status | Development Focus |
|------------|------------|---------|---------|-------------------|
| **`TPB-Ecomm-FE-and-BE/`** | **React + NestJS** | **Modern E-commerce** | **✅ ACTIVE DEVELOPMENT** | **🚀 PRIMARY FOCUS** |
| `repositories/back-end/` | Rails + PostgreSQL | Core API | ⚠️ Production (maintenance only) | ⚠️ Critical fixes only |
| `repositories/cms-fe-angular/` | Angular 8 | Content Management | ⚠️ Legacy (will be replaced) | ⚠️ No development |
| `repositories/front-end/` | Vue.js 2 | Kiosk Displays | ⚠️ Legacy (NOT being rebuilt) | ⚠️ Critical fixes only |
| `modern-frontend/` | Next.js | Colleague's experiment | 🚫 Ignore completely | 🚫 Do not work on |

## 🎯 **CURRENT DEVELOPMENT STRATEGY**

### **✅ APPROACH SELECTED: E-commerce Foundation**
- **Primary Target**: `TPB-Ecomm-FE-and-BE/` project modernization
- **Status**: Active development and modernization
- **Timeline**: 3-month modernization phase
- **Team**: 3-4 developers assigned

### **❌ APPROACH REJECTED: Legacy Rebuild**
- **Legacy Systems**: `repositories/` (Vue.js, Rails, Angular)
- **Status**: Maintained for production stability only
- **Development**: NOT our primary focus
- **Reason**: Too expensive, too slow, limited V2 seeding value

### **Phase 1: E-commerce Modernization (Current)**
- **Objective**: Modernize and secure the e-commerce project
- **Key Tasks**: Dependency updates, security fixes, component extraction
- **Timeline**: 3 months (Months 1-3)

### **Phase 2: V2 Spine Development (Next)**
- **Objective**: Build V2 foundation using ported patterns
- **Key Tasks**: User accounts, data enrichment, admin UI
- **Timeline**: 3 months (Months 4-6)

### **Phase 3: Revenue Engine Development (Future)**
- **Objective**: Launch dual revenue engines
- **Key Tasks**: Affiliate feeds, data SaaS, agent integration
- **Timeline**: 6 months (Months 7-12)

## 🚀 **WHAT TO WORK ON RIGHT NOW**

### **✅ PRIMARY DEVELOPMENT TARGETS**
1. **`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce/`** - React frontend modernization
2. **`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API/`** - NestJS backend modernization
3. **Dependency Updates**: React 17→18, NestJS 8→10, Node 14→18+
4. **Security Fixes**: JWT vulnerabilities, input validation
5. **Component Extraction**: ProductCard, cart management, auth patterns

### **⚠️ MAINTENANCE ONLY (Don't Focus Here)**
1. **`repositories/back-end/`** - Rails API (critical fixes only)
2. **`repositories/front-end/`** - Vue.js kiosk (critical fixes only)
3. **`repositories/cms-fe-angular/`** - Angular CMS (will be replaced)

### **🚫 IGNORE COMPLETELY**
1. **`modern-frontend/`** - Colleague's experiment (not our strategy)

## 📚 **KEY DOCUMENTATION**

### **Essential Reading (Start Here)**
1. **`PROJECT_STATUS.md`** - Current project state and decisions
2. **`DEVELOPER_ONBOARDING.md`** - Guide for new developers
3. **`TPB-Ecomm-FE-and-BE/SETUP_GUIDE.md`** - How to run the project
4. **`TPB-Ecomm-FE-and-BE/LOCAL_DEVELOPMENT.md`** - Development setup

### **Context & Analysis (Read When Needed)**
1. **`analysis-workflow/OVERVIEW.md`** - Strategic decision and analysis overview
2. **`future-considerations/`** - Strategic business objectives
3. **`analysis-workflow/`** - Technical analysis and decisions

### **Reference (Consult As Needed)**
1. **`repositories/`** - Legacy systems (for understanding, not development)
2. **`knowledge-bases/`** - Detailed technical analysis

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
