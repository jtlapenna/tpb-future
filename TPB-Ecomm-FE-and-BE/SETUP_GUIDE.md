# The Peak Beyond E-commerce V2 - Complete Setup Guide

## 🎯 Project Overview

This is The Peak Beyond's modern e-commerce platform (V2) built with:
- **Frontend**: React 17 + TypeScript + Redux Toolkit + Material-UI
- **Backend**: NestJS + TypeScript + TypeORM + PostgreSQL
- **Authentication**: AWS Cognito integration
- **Database**: PostgreSQL with Treez integration

## 🏗️ Architecture

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

- **Node.js**: **16.20.2** (required - use `nvm use 16.20.2`)
- **npm**: 8.x or higher
- **PostgreSQL**: 12.x or higher
- **AWS Account**: For Cognito and Secrets Manager

### 1. Clone and Setup

```bash
# Navigate to the e-commerce project
cd TPB-Ecomm-FE-and-BE

# Switch to required Node.js version
nvm use 16.20.2

# Make script executable and start servers
chmod +x start-servers.sh
./start-servers.sh
```

### 2. What the Script Does

The `start-servers.sh` script automatically:
- ✅ Switches to Node.js 16.20.2
- ✅ Creates `.env` file if missing
- ✅ Starts backend server (NestJS API)
- ✅ Starts frontend server (React app)
- ✅ Uses Node.js compatibility fixes
- ✅ Uses sass instead of node-sass
- ✅ Runs both servers in background with logs

### 3. Environment Configuration

#### Backend Environment (.env)

Create `ThePeakBeyond_eCommerce_API/.env`:

```env
# Server Configuration
PORT=3001
NODE_ENV=development

# Database Configuration (Local Development)
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=tpb_user
DB_PASSWORD=tpb_password
DB_DATABASE=tpb_ecommerce

# AWS Configuration
S3_AWS_ACCESS_KEY=your_aws_access_key
S3_SECRET_KEY=your_aws_secret_key
S3_REGION=us-west-2

# AWS Secrets Manager
API_STAGE_POSTGRES=your_postgres_secret_name

# Treez Integration
TREEZ_API_URL=https://api.treez.io
TREEZ_API_KEY=your_treez_api_key
```

#### Frontend Environment (.env)

Create `ThePeakBeyond_eCommerce/.env`:

```env
# API Configuration
REACT_APP_EXTERNAL_API_URL=http://localhost:3001

# AWS Cognito Configuration
REACT_APP_AWS_REGION=us-west-2
REACT_APP_USER_POOL_ID=your_cognito_user_pool_id
REACT_APP_USER_POOL_WEB_CLIENT_ID=your_cognito_client_id

# Development Settings
REACT_APP_ENVIRONMENT=development
```

### 3. Database Setup

#### Option A: Local PostgreSQL

```bash
# Create database
createdb tpb_ecommerce

# Run migrations (when available)
cd ThePeakBeyond_eCommerce_API
npm run migration:run
```

#### Option B: Docker PostgreSQL

```bash
# Run PostgreSQL in Docker
docker run --name tpb-postgres \
  -e POSTGRES_USER=tpb_user \
  -e POSTGRES_PASSWORD=tpb_password \
  -e POSTGRES_DB=tpb_ecommerce \
  -p 5432:5432 \
  -d postgres:12
```

### 4. Start the Applications

#### Terminal 1: Backend API
```bash
cd ThePeakBeyond_eCommerce_API
npm run start:dev
```
**Backend will run on:** http://localhost:3001
**API Documentation:** http://localhost:3001/api

#### Terminal 2: Frontend
```bash
cd ThePeakBeyond_eCommerce
npm start
```
**Frontend will run on:** http://localhost:3000

## 📁 Project Structure

### Backend (NestJS API)
```
ThePeakBeyond_eCommerce_API/
├── src/
│   ├── modules/           # Feature modules
│   │   ├── product/       # Product management
│   │   ├── brand/         # Brand management
│   │   ├── store/         # Store management
│   │   ├── favorite/      # User favorites
│   │   └── treez/         # Treez integration
│   ├── models/            # Database entities
│   ├── providers/         # External services
│   │   ├── aws/           # AWS services
│   │   └── database/      # Database configuration
│   └── common/            # Shared utilities
├── test/                  # Test files
└── package.json
```

### Frontend (React App)
```
ThePeakBeyond_eCommerce/
├── src/
│   ├── components/        # React components
│   │   ├── _ui/           # Reusable UI components
│   │   ├── login/         # Authentication components
│   │   ├── products/      # Product-related components
│   │   └── cart/          # Shopping cart components
│   ├── services/          # API services
│   ├── state/             # Redux store
│   │   ├── user/          # User state management
│   │   ├── cart/          # Cart state management
│   │   └── favorites/     # Favorites state management
│   ├── types/             # TypeScript interfaces
│   └── utils/             # Utility functions
├── public/                # Static assets
└── package.json
```

## 🔧 Development Workflow

### 1. Backend Development

```bash
# Start development server with hot reload
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

### 2. Frontend Development

```bash
# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build

# Build for production with production env
npm run build:prod
```

### 3. Database Management

```bash
# Generate migration (when TypeORM CLI is configured)
npm run migration:generate -- -n MigrationName

# Run migrations
npm run migration:run

# Revert last migration
npm run migration:revert
```

## 🔐 Authentication Flow

The application uses AWS Cognito for authentication:

1. **User Registration/Login**: Handled through Cognito
2. **JWT Tokens**: Stored in cookies for session management
3. **API Authorization**: Bearer token sent with each request
4. **Auto-logout**: On 401 responses, user is redirected to login

## 🛒 Key Features

### User Management
- User registration and login
- Profile management
- Store selection
- Purchase history

### Product Management
- Product browsing and search
- Category filtering
- Brand filtering
- Product details and images

### Shopping Experience
- Add to cart functionality
- Favorites system
- Order management
- Treez integration for inventory

### Store Management
- Multi-store support
- Store-specific configurations
- Store picker interface

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

## 🐛 Troubleshooting

### Common Issues

#### 1. Node Sass Compilation Error
```bash
# Error: Node Sass does not yet support your current environment
# Solution: Already fixed! The project now uses 'sass' instead of 'node-sass'
```

#### 2. Digital Envelope Routines Error
```bash
# Error: error:0308010C:digital envelope routines::unsupported
# Solution: The start-servers.sh script automatically uses --openssl-legacy-provider
```

#### 3. Database Connection Issues
```bash
# Check if PostgreSQL is running
brew services start postgresql  # macOS
sudo systemctl start postgresql  # Linux

# Test connection
psql -h localhost -U tpb_user -d tpb_ecommerce
```

#### 2. AWS Configuration Issues
- Verify AWS credentials are correct
- Check AWS region configuration
- Ensure Secrets Manager permissions

#### 3. Port Conflicts
- Backend: 3001 (configurable via PORT env var)
- Frontend: 3000 (React default)

#### 4. CORS Issues
- Backend has CORS enabled for development
- Check API URL configuration in frontend

### Environment Variables Checklist

**Backend (.env):**
- [ ] PORT
- [ ] DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_DATABASE
- [ ] S3_AWS_ACCESS_KEY, S3_SECRET_KEY, S3_REGION
- [ ] API_STAGE_POSTGRES

**Frontend (.env):**
- [ ] REACT_APP_EXTERNAL_API_URL
- [ ] REACT_APP_AWS_REGION
- [ ] REACT_APP_USER_POOL_ID
- [ ] REACT_APP_USER_POOL_WEB_CLIENT_ID

## 📚 Additional Resources

### Documentation
- [NestJS Documentation](https://docs.nestjs.com/)
- [React Documentation](https://reactjs.org/docs/)
- [Redux Toolkit Documentation](https://redux-toolkit.js.org/)
- [TypeORM Documentation](https://typeorm.io/)

### Development Tools
- **API Testing**: Use the Swagger UI at http://localhost:3001/api
- **Database Management**: Use pgAdmin or similar PostgreSQL client
- **State Management**: Redux DevTools browser extension

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

### Environment Configuration
- Use `.env.prod` files for production
- Configure production database
- Set up production AWS resources
- Configure production Treez API credentials

## 📞 Support

For development questions or issues:
1. Check this setup guide
2. Review the API documentation at http://localhost:3001/api
3. Check the console logs for error messages
4. Verify environment configuration

---

**Last Updated**: December 2024
**Version**: 2.0
