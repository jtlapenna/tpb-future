# Local Development Configuration

## Environment Files Setup

### Backend Environment (.env)

Create `ThePeakBeyond_eCommerce_API/.env` with the following content:

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

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=24h
```

### Frontend Environment (.env)

Create `ThePeakBeyond_eCommerce/.env` with the following content:

```env
# API Configuration
REACT_APP_EXTERNAL_API_URL=http://localhost:3001

# AWS Cognito Configuration
REACT_APP_AWS_REGION=us-west-2
REACT_APP_USER_POOL_ID=your_cognito_user_pool_id
REACT_APP_USER_POOL_WEB_CLIENT_ID=your_cognito_client_id

# Development Settings
REACT_APP_ENVIRONMENT=development

# Optional: Analytics
REACT_APP_ANALYTICS_ID=your_analytics_id
```

## Database Setup Commands

### Option 1: Local PostgreSQL
```bash
# Create database
createdb tpb_ecommerce

# Create user (if needed)
psql -c "CREATE USER tpb_user WITH PASSWORD 'tpb_password';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE tpb_ecommerce TO tpb_user;"
```

### Option 2: Docker PostgreSQL
```bash
# Run PostgreSQL in Docker
docker run --name tpb-postgres \
  -e POSTGRES_USER=tpb_user \
  -e POSTGRES_PASSWORD=tpb_password \
  -e POSTGRES_DB=tpb_ecommerce \
  -p 5432:5432 \
  -d postgres:12

# Connect to test
docker exec -it tpb-postgres psql -U tpb_user -d tpb_ecommerce
```

## Quick Start Commands

```bash
# 1. Install dependencies
cd ThePeakBeyond_eCommerce_API && npm install
cd ../ThePeakBeyond_eCommerce && npm install

# 2. Start backend (Terminal 1)
cd ThePeakBeyond_eCommerce_API
npm run start:dev

# 3. Start frontend (Terminal 2)
cd ThePeakBeyond_eCommerce
npm start
```

## Verification

- Backend API: http://localhost:3001
- API Documentation: http://localhost:3001/api
- Frontend App: http://localhost:3000

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL status
brew services list | grep postgresql  # macOS
sudo systemctl status postgresql      # Linux

# Test connection
psql -h localhost -U tpb_user -d tpb_ecommerce -c "SELECT version();"
```

### Port Conflicts
- Backend: 3001 (change PORT in .env if needed)
- Frontend: 3000 (React default, will prompt to use different port if busy)

### AWS Configuration
- Ensure AWS credentials are properly configured
- Check AWS region matches your resources
- Verify Secrets Manager permissions
