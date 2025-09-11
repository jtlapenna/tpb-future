# Developer Onboarding Guide

## 🎯 **WELCOME TO TPB FUTURE PROJECT**

This guide will help you understand the project structure, current status, and what you should focus on as a new developer or AI agent.

## 📋 **QUICK START CHECKLIST**

### **✅ FIRST THINGS TO READ**
1. **Project Status**: `PROJECT_STATUS.md` - Current project state and decisions
2. **Main README**: `README.md` - Project overview and structure
3. **E-commerce Setup**: `TPB-Ecomm-FE-and-BE/SETUP_GUIDE.md` - How to run the project
4. **Local Development**: `TPB-Ecomm-FE-and-BE/LOCAL_DEVELOPMENT.md` - Development setup

### **✅ FIRST THINGS TO DO**
1. **Clone the repository** and navigate to the project
2. **Read the project status** to understand our strategy
3. **Set up the e-commerce project** using the setup guides
4. **Run the startup script** to get everything running locally

## 🎯 **PROJECT STRATEGY - WHAT WE'RE DOING**

### **✅ OUR APPROACH: E-commerce Foundation**
We are using the **TPB-Ecomm-FE-and-BE** project as our foundation for V2 development.

**Why This Approach**:
- ✅ **80-90% code reusability** from existing e-commerce project
- ✅ **6-12 months faster** than rebuilding from legacy
- ✅ **$50k-100k cost savings** vs complete rebuild
- ✅ **Direct V2 seeding** - every component ports to V2 spine
- ✅ **Modern architecture** already in place (React + TypeScript + Redux)

### **❌ WHAT WE'RE NOT DOING**
- ❌ **NOT rebuilding** the legacy Vue.js system (`repositories/front-end/`)
- ❌ **NOT modernizing** the legacy Rails API (`repositories/back-end/`) - except critical fixes
- ❌ **NOT working on** the Angular CMS (`repositories/cms-fe-angular/`) - will be replaced
- ❌ **NOT using** the modern-frontend experiment (`modern-frontend/`) - colleague's experiment

## 📁 **PROJECT STRUCTURE - WHAT TO FOCUS ON**

### **🎯 PRIMARY DEVELOPMENT TARGETS**

#### **TPB-Ecomm-FE-and-BE/** - **YOUR MAIN FOCUS**
```
TPB-Ecomm-FE-and-BE/
├── ThePeakBeyond_eCommerce/          # React Frontend - WORK HERE
│   ├── src/components/               # React components
│   ├── src/services/                 # API services
│   ├── src/state/                    # Redux state management
│   └── package.json                  # Dependencies to update
├── ThePeakBeyond_eCommerce_API/      # NestJS Backend - WORK HERE
│   ├── src/modules/                  # API modules
│   ├── src/models/                   # Database entities
│   └── package.json                  # Dependencies to update
├── SETUP_GUIDE.md                    # READ THIS FIRST
├── LOCAL_DEVELOPMENT.md              # Development setup
└── start-dev.sh                      # Quick startup script
```

**Status**: ✅ **ACTIVE DEVELOPMENT** - This is where you should work
**Priority**: 🚀 **HIGHEST** - This is our main development target

### **⚠️ MAINTENANCE-ONLY SYSTEMS**

#### **repositories/** - **DON'T FOCUS HERE**
```
repositories/
├── back-end/          # Rails API - Maintain for production only
├── front-end/         # Vue.js Kiosk - Maintain for production only
└── cms-fe-angular/    # Angular CMS - Will be replaced
```

**Status**: ⚠️ **MAINTENANCE ONLY** - Keep production running, don't rebuild
**Priority**: ⚠️ **LOW** - Only critical fixes, not our main focus

### **🚫 IGNORE THESE**

#### **modern-frontend/** - **IGNORE COMPLETELY**
```
modern-frontend/       # Colleague's experiment - NOT our strategy
```

**Status**: 🚫 **IGNORE** - Not part of our approach
**Priority**: 🚫 **NONE** - Do not work on or reference this code

## 🚀 **CURRENT DEVELOPMENT PHASES**

### **Phase 1: E-commerce Modernization (Months 1-3) - CURRENT**
**Objective**: Modernize and secure the e-commerce project

#### **Weeks 1-2: Foundation (CURRENT PRIORITY)**
- [ ] **Dependency Updates**: React 17→18, NestJS 8→10, Node 14→18+
- [ ] **Security Hardening**: Fix JWT vulnerabilities, implement secure tokens
- [ ] **Build Tool Migration**: Create React App → Vite
- [ ] **TypeScript Updates**: Latest version with proper types

#### **Weeks 3-8: Core Development**
- [ ] **Component Library**: Extract ProductCard and reusable components
- [ ] **State Management**: Port Redux Toolkit patterns
- [ ] **API Integration**: Connect to V1 Rails API
- [ ] **Authentication**: Secure JWT handling with httpOnly cookies

#### **Weeks 9-12: Integration & Testing**
- [ ] **V1 Integration**: Connect to existing Rails backend
- [ ] **POS Integration**: Implement POS system connections
- [ ] **Testing**: Comprehensive test coverage
- [ ] **Documentation**: Complete development guides

### **Phase 2: V2 Spine Development (Months 4-6)**
**Objective**: Build V2 foundation using ported patterns

- [ ] **User Accounts**: Extend AWS Cognito integration
- [ ] **Data Enrichment**: Add terpenes/effects modeling
- [ ] **Admin UI**: Replace Angular CMS with modern interface
- [ ] **Agent Integration**: Add consent patterns for agents

### **Phase 3: Revenue Engine Development (Months 7-12)**
**Objective**: Launch dual revenue engines

- [ ] **Engine A**: Affiliate feeds and content management
- [ ] **Engine B**: Data SaaS and analytics platform
- [ ] **Partner Integration**: API ecosystem and documentation
- [ ] **Agent Economy**: Full agent-ready platform

## 🛠️ **DEVELOPMENT SETUP**

### **Prerequisites**
- Node.js 18+ (we're upgrading from 14)
- npm 8+
- PostgreSQL 12+
- Git

### **Quick Setup**
```bash
# 1. Clone and navigate to project
cd TPB-Ecomm-FE-and-BE

# 2. Run the startup script
./start-dev.sh

# 3. Follow the setup guide
# Read: SETUP_GUIDE.md
# Read: LOCAL_DEVELOPMENT.md
```

### **Manual Setup**
```bash
# Backend setup
cd ThePeakBeyond_eCommerce_API
npm install
# Create .env file (see LOCAL_DEVELOPMENT.md)
npm run start:dev

# Frontend setup (new terminal)
cd ThePeakBeyond_eCommerce
npm install
# Create .env file (see LOCAL_DEVELOPMENT.md)
npm start
```

## 📚 **KEY DOCUMENTATION TO READ**

### **Essential Reading (Start Here)**
1. **`PROJECT_STATUS.md`** - Current project state and decisions
2. **`TPB-Ecomm-FE-and-BE/SETUP_GUIDE.md`** - How to run the project
3. **`TPB-Ecomm-FE-and-BE/LOCAL_DEVELOPMENT.md`** - Development setup
4. **`TPB-Ecomm-FE-and-BE/README.md`** - E-commerce project overview

### **Context & Analysis (Read When Needed)**
1. **`future-considerations/`** - Strategic business objectives
2. **`analysis-workflow/`** - Technical analysis and decisions
3. **`cursor_rules/`** - Development guidelines and patterns

### **Reference (Consult As Needed)**
1. **`repositories/`** - Legacy systems (for understanding, not development)
2. **`knowledge-bases/`** - Detailed technical analysis

## 🎯 **WHAT TO WORK ON RIGHT NOW**

### **Immediate Tasks (Next 30 Days)**
1. **Dependency Updates**:
   - React 17 → React 18 (moderate complexity, AI-assisted)
   - NestJS 8 → NestJS 10
   - Material-UI v4 → v5
   - Node 14 → Node 18+

2. **Security Fixes**:
   - Fix JWT localStorage vulnerability → httpOnly cookies
   - Implement secure token handling
   - Add input validation

3. **Build Tool Migration**:
   - Create React App → Vite (better performance)
   - Update TypeScript to latest version

### **Short-term Tasks (Next 90 Days)**
1. **Component Extraction**:
   - Extract ProductCard to shared library
   - Port cart management patterns
   - Create reusable UI components

2. **V1 Integration**:
   - Connect to existing Rails API
   - Implement POS system integrations
   - Add analytics and monitoring

3. **Testing & Documentation**:
   - Implement comprehensive test coverage
   - Complete development guides
   - Document all patterns and practices

## ⚠️ **IMPORTANT NOTES**

### **DO NOT WORK ON:**
- ❌ Legacy Vue.js frontend (`repositories/front-end/`)
- ❌ Legacy Rails API (`repositories/back-end/`) - except critical fixes
- ❌ Legacy Angular CMS (`repositories/cms-fe-angular/`)
- ❌ Modern frontend experiment (`modern-frontend/`)

### **DO WORK ON:**
- ✅ E-commerce frontend (`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce/`)
- ✅ E-commerce backend (`TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API/`)
- ✅ Documentation and setup guides
- ✅ Component library extraction
- ✅ V1 API integration

### **CURRENT PRIORITIES:**
1. **Dependency Updates**: React 17→18, security fixes
2. **Component Extraction**: ProductCard, cart management, auth patterns
3. **V1 Integration**: Connect to existing Rails API
4. **Documentation**: Complete setup and development guides

## 🤖 **FOR AI AGENTS**

### **Primary Focus**
- Work on `TPB-Ecomm-FE-and-BE/` modernization
- Current phase: Phase 1 - E-commerce modernization (3 months)
- Key tasks: Dependency updates, security fixes, component extraction

### **Reference Documents**
- Use analysis documents for context and decisions
- Follow cursor_rules for code quality
- Reference setup guides for development environment

### **What NOT to Do**
- Don't work on legacy systems (`repositories/`)
- Don't reference the modern-frontend experiment
- Don't suggest rebuilding from Vue.js legacy

## 📞 **GETTING HELP**

### **For Technical Issues**
1. Check documentation in `TPB-Ecomm-FE-and-BE/`
2. Review setup guides and local development docs
3. Check project status and README files

### **For Strategic Questions**
1. Review `future-considerations/` documents
2. Check `analysis-workflow/` for technical decisions
3. Read `PROJECT_STATUS.md` for current state

### **For Development Questions**
1. Follow `cursor_rules/` for code quality
2. Use setup guides for environment issues
3. Reference analysis documents for context

## 🎯 **SUCCESS METRICS**

### **Phase 1 Targets (3 months)**
- [ ] React 18 + TypeScript 5.0+ implemented
- [ ] Security vulnerabilities fixed (JWT, input validation)
- [ ] Component library extracted and documented
- [ ] V1 API integration working
- [ ] Test coverage ≥ 80%
- [ ] Development environment fully documented

### **V2 Readiness Targets (12 months)**
- [ ] User accounts MVP deployed
- [ ] Admin UI replacing Angular CMS
- [ ] Data enrichment (terpenes/effects) implemented
- [ ] Revenue Engine A (affiliate feeds) operational
- [ ] Revenue Engine B (data SaaS) operational
- [ ] Agent integration patterns implemented

---

**Remember**: We are building V2 using the e-commerce project as our foundation. The legacy systems are maintained for production stability only. Focus your efforts on `TPB-Ecomm-FE-and-BE/` modernization.

**Welcome to the team!** 🚀
