# The Peak Beyond E-commerce V2

## 🎯 **PROJECT STATUS: ACTIVE DEVELOPMENT**

**Current Phase**: Phase 1 - E-commerce Modernization  
**Timeline**: 3 months (Months 1-3)  
**Team**: 3-4 developers assigned  
**Priority**: 🚀 **HIGHEST** - This is our primary development focus

## 🚨 **IMMEDIATE PRIORITY: DEPENDENCY MODERNIZATION**

**CRITICAL**: The project is using severely outdated dependencies that pose security risks and compatibility issues. **ALL development must start with dependency updates.**

### **Outdated Dependencies (Security Risk)**
- **React**: 17.0.2 → **18.x** (Major version behind)
- **TypeScript**: 4.3.5 → **5.x** (Major version behind)  
- **Material-UI**: v4.12.3 → **v5 (MUI)** (Major version behind)
- **NestJS**: 8.0.0 → **10.x** (Major version behind)
- **Node.js**: 14 → **18+** (Major security risk)
- **Create React App**: 4.0.3 → **Vite** (Deprecated)

### **Why This Must Be Done First**
1. **Security Vulnerabilities**: Outdated dependencies have known security issues
2. **Compatibility Issues**: Modern tools and libraries won't work with old versions
3. **Development Experience**: Old versions lack modern features and performance improvements
4. **Future-Proofing**: New features require modern dependency versions  

## Project Overview

This is The Peak Beyond's modern e-commerce platform (V2) - **OUR FOUNDATION FOR V2 DEVELOPMENT**. This project was selected as our primary development target after comprehensive analysis showed it provides 80-90% code reusability and significant time/cost savings over rebuilding from legacy systems.

## 🏗️ Architecture

### Technology Stack
- **Frontend**: React 17 → **React 18** + TypeScript + Redux Toolkit + Material-UI v4 → **v5**
- **Backend**: NestJS 8 → **NestJS 10** + TypeScript + TypeORM + PostgreSQL
- **Authentication**: AWS Cognito integration
- **Database**: PostgreSQL with Treez POS integration
- **Deployment**: Azure (configured via azure-pipelines.yml)

### **🚨 CRITICAL MODERNIZATION TASKS (DO FIRST)**

**IMMEDIATE PRIORITY**: Update all outdated dependencies before any feature development.

#### **Phase 0: Frontend Updates (Weeks 1-2)**
1. **React 17 → 18** (S-M complexity, 8-16 hours)
   ```bash
   npm install react@^18.0.0 react-dom@^18.0.0 @types/react@^18.0.0 @types/react-dom@^18.0.0
   ```
   - Fix React 18 strict mode and new JSX transform
   - **AI Help**: Cursor can handle breaking changes automatically

2. **TypeScript 4.3 → 5.x** (S complexity, 4-8 hours)
   ```bash
   npm install typescript@^5.0.0 @types/node@^18.0.0
   ```
   - Fix stricter type checking and new compiler options
   - **AI Help**: Cursor excels at TypeScript error fixes

3. **Material-UI v4 → v5 (MUI)** (M complexity, 16-32 hours)
   ```bash
   npm uninstall @material-ui/core @material-ui/icons @material-ui/lab @material-ui/pickers
   npm install @mui/material@^5.0.0 @mui/icons-material@^5.0.0 @emotion/react @emotion/styled
   ```
   - Fix theme structure, component props, and styling system
   - **AI Help**: Cursor can help with component migration patterns

4. **Create React App → Vite** (M complexity, 16-32 hours)
   ```bash
   npm uninstall react-scripts
   npm install vite @vitejs/plugin-react
   ```
   - Create `vite.config.ts`, update scripts, fix import paths
   - **AI Help**: Cursor can automate migration steps

5. **Node.js 14 → 18+** (S complexity, 2-4 hours)
   - Update `.nvmrc` and `package.json` engines
   - **AI Help**: Cursor can help with environment setup

#### **Phase 1: Backend Updates (Weeks 2-3)**
6. **NestJS 8 → 10** (M-L complexity, 24-48 hours)
   ```bash
   npm install @nestjs/common@^10.0.0 @nestjs/core@^10.0.0 @nestjs/platform-express@^10.0.0
   ```
   - Fix decorator changes, module structure, guards
   - **AI Help**: Cursor can help with migration patterns

7. **TypeORM 0.2 → 0.3** (M complexity, 16-32 hours)
   ```bash
   npm install typeorm@^0.3.0 pg@^8.11.0
   ```
   - Fix entity definitions, query builders, migrations
   - **AI Help**: Cursor can help with entity migration

#### **Phase 2: Security & Quality (Weeks 3-4)**
8. **Security Hardening** (M complexity, 16-32 hours)
   - JWT localStorage → httpOnly cookies, input validation
   - **AI Help**: Cursor can help with security patterns

9. **Code Quality Tools** (S complexity, 4-8 hours)
   ```bash
   npm install eslint prettier eslint-config-prettier @typescript-eslint/eslint-plugin
   ```
   - **AI Help**: Cursor excels at code quality fixes

### **🎯 Success Criteria**
- **Week 2**: React 18, TypeScript 5, MUI v5, Vite working
- **Week 3**: NestJS 10, TypeORM 0.3, all APIs functional  
- **Week 4**: Security hardened, code quality tools configured

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend │    │   NestJS API    │    │   PostgreSQL    │
│   (Port 3000)   │◄──►│   (Port 3001)   │◄──►│   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS Cognito   │    │   AWS Secrets   │    │   Treez API     │
│   Auth Service  │    │   Manager       │    │   Integration   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- **Node.js 16.20.2** (required - use `nvm use 16.20.2`)
- npm 8.x or higher
- PostgreSQL 12.x or higher

### 2-Step Setup
1. **Switch Node.js version:**
   ```bash
   nvm use 16.20.2
   ```

2. **Start both servers:**
   ```bash
   cd TPB-Ecomm-FE-and-BE
   chmod +x start-servers.sh
   ./start-servers.sh
   ```

**That's it!** The app will be running at:
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:3001
- AWS Account (for Cognito and Secrets Manager)

### What the Script Does
The `start-servers.sh` script automatically:
- ✅ Switches to Node.js 16.20.2
- ✅ Creates `.env` file if missing
- ✅ Starts backend server (NestJS API)
- ✅ Starts frontend server (React app)
- ✅ Uses Node.js compatibility fixes
- ✅ Uses sass instead of node-sass
- ✅ Runs both servers in background with logs

### Environment Variables

**Backend** (`ThePeakBeyond_eCommerce_API/.env`):
```env
PORT=3001
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=tpb_user
DB_PASSWORD=tpb_password
DB_DATABASE=tpb_ecommerce
```

**Frontend** (`ThePeakBeyond_eCommerce/.env`):
```env
REACT_APP_EXTERNAL_API_URL=http://localhost:3001
REACT_APP_AWS_REGION=us-west-2
REACT_APP_USER_POOL_ID=your_cognito_user_pool_id
REACT_APP_USER_POOL_WEB_CLIENT_ID=your_cognito_client_id
```

### 3. Start Development Servers

**Terminal 1 - Backend:**
```bash
cd ThePeakBeyond_eCommerce_API
npm run start:dev
```

**Terminal 2 - Frontend:**
```bash
cd ThePeakBeyond_eCommerce
npm start
```

### 4. Access Applications
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **API Documentation**: http://localhost:3001/api

## 📁 Project Structure

### Backend (`ThePeakBeyond_eCommerce_API/`)
```
src/
├── modules/              # Feature modules
│   ├── product/          # Product management
│   ├── brand/            # Brand management
│   ├── store/            # Store management
│   ├── favorite/         # User favorites
│   ├── category/         # Category management
│   ├── company/          # Company management
│   └── treez/            # Treez POS integration
├── models/               # Database entities
│   ├── brands/           # Brand entity
│   ├── companies/        # Company entity
│   ├── favorites/        # Favorites entity
│   ├── product/          # Product & Category entities
│   ├── stores/           # Store entities
│   └── tagging/          # Tag entities
├── providers/            # External services
│   ├── aws/              # AWS services
│   └── database/         # Database configuration
├── common/               # Shared utilities
│   ├── constants/        # Application constants
│   ├── decorators/       # Custom decorators
│   ├── guards/           # Authentication guards
│   └── helpers/          # Helper functions
└── database/             # Database queries
```

### Frontend (`ThePeakBeyond_eCommerce/`)
```
src/
├── components/           # React components
│   ├── _ui/              # Reusable UI components
│   ├── login/            # Authentication components
│   ├── products/         # Product-related components
│   ├── cart/             # Shopping cart components
│   ├── favorites/        # Favorites components
│   └── dashboard/        # User dashboard
├── services/             # API services
│   ├── authentication.service.ts
│   ├── http-client.service.ts
│   └── treez.service.ts
├── state/                # Redux store
│   ├── user/             # User state management
│   ├── cart/             # Cart state management
│   └── favorites/        # Favorites state management
├── types/                # TypeScript interfaces
├── utils/                # Utility functions
└── styles/               # SCSS styles
```

## 🔧 Development

### Backend Development
```bash
# Development server with hot reload
npm run start:dev

# Run tests
npm run test

# Run tests with coverage
npm run test:cov

# Lint code
npm run lint

# Build for production
npm run build
```

### Frontend Development
```bash
# Development server
npm start

# Run tests
npm test

# Build for production
npm run build

# Build for production with production env
npm run build:prod
```

## 🔐 Authentication & Security

### Authentication Flow
1. **User Registration/Login**: Handled through AWS Cognito
2. **JWT Tokens**: Stored in cookies for session management
3. **API Authorization**: Bearer token sent with each request
4. **Auto-logout**: On 401 responses, user is redirected to login

### Security Features
- JWT-based authentication
- CORS configuration
- Input validation with DTOs
- Environment-based configuration
- AWS Secrets Manager integration

## 🛒 Key Features

### User Management
- User registration and login via AWS Cognito
- Profile management
- Store selection and management
- Purchase history tracking

### Product Management
- Product browsing and search
- Category and brand filtering
- Product details with images
- Inventory integration with Treez

### Shopping Experience
- Add to cart functionality
- Favorites system
- Order management
- Multi-store support

### Store Management
- Multi-store configuration
- Store-specific settings
- Store picker interface
- Store-specific product catalogs

## 🔌 API Endpoints

### Authentication
- `POST /Auth/login` - User login
- `POST /Auth/register` - User registration

### Products
- `GET /products` - List products
- `GET /products/:id` - Get product details
- `GET /products/search` - Search products

### Brands
- `GET /brands` - List brands
- `GET /brands/:id` - Get brand details

### Stores
- `GET /stores` - List stores
- `GET /stores/:id` - Get store details

### Favorites
- `GET /favorites` - Get user favorites
- `POST /favorites` - Add to favorites
- `DELETE /favorites/:id` - Remove from favorites

## 🗄️ Database Schema

### Core Entities
- **Products**: Product information, pricing, inventory
- **Brands**: Brand information and metadata
- **Stores**: Store configuration and settings
- **Categories**: Product categorization
- **Favorites**: User favorite products
- **Companies**: Company information
- **TagInfo**: Product tagging system

### Relationships
- Products belong to Brands and Categories
- Stores have multiple Products
- Users can have multiple Favorites
- Companies can have multiple Stores

## 🔄 Integration Points

### Treez POS Integration
- Real-time inventory synchronization
- Order processing
- Customer management
- Product catalog sync

### AWS Services
- **Cognito**: User authentication and management
- **Secrets Manager**: Secure configuration storage
- **S3**: File storage (when implemented)

## 🚀 Deployment

### Production Build
```bash
# Backend
cd ThePeakBeyond_eCommerce_API
npm run build
npm run start:prod

# Frontend
cd ThePeakBeyond_eCommerce
npm run build:prod
```

### Azure Deployment
- Configured via `azure-pipelines.yml`
- Automatic deployment on push to main branch
- Environment-specific configuration

## 📚 Documentation

- **Setup Guide**: [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- **Quick Start**: [QUICK_START.md](./QUICK_START.md)
- **API Documentation**: Available at http://localhost:3001/api when running

## 🐛 Troubleshooting

### Common Issues
1. **Node Sass Compilation Error**: ✅ **FIXED!** Project now uses 'sass' instead of 'node-sass'
2. **Digital Envelope Routines Error**: ✅ **FIXED!** Script uses --openssl-legacy-provider
3. **Database Connection**: Ensure PostgreSQL is running and credentials are correct
4. **AWS Configuration**: Verify AWS credentials and region settings
3. **Port Conflicts**: Backend uses 3001, frontend uses 3000
4. **CORS Issues**: Backend has CORS enabled for development

### Environment Variables Checklist
- [ ] Backend `.env` file created with database credentials
- [ ] Frontend `.env` file created with API URL and Cognito settings
- [ ] PostgreSQL database created and accessible
- [ ] AWS credentials configured (if using AWS services)

## 🔮 Future Development

### Planned Features
- Enhanced product search and filtering
- Advanced analytics and reporting
- Mobile app development
- Enhanced Treez integration
- Multi-language support

### Technical Improvements
- Microservices architecture
- GraphQL API
- Real-time notifications
- Advanced caching strategies
- Performance optimizations

## 📞 Support

For development questions or issues:
1. Check the setup guides
2. Review API documentation
3. Check console logs for errors
4. Verify environment configuration

---

**Last Updated**: December 2024  
**Version**: 2.0  
**Status**: Development Ready
