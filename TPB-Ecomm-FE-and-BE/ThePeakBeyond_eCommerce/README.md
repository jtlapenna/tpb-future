# The Peak Beyond E-commerce Frontend

## 🚀 Quick Start

### Prerequisites
- **Node.js 16.20.2** (required - use `nvm use 16.20.2`)
- npm 8.x or higher

### Setup
1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```
   (Or create `.env` manually with the variables from `.env.example`)

3. **Start the development server:**
   ```bash
   npm start
   ```

4. **Visit the app:**
   - Frontend: http://localhost:3000
   - Backend: http://localhost:3001 (make sure backend is running)

## Environment Variables

The app requires these environment variables in `.env`:

```bash
REACT_APP_API_URL=http://localhost:3001
REACT_APP_AWS_REGION=us-east-1
REACT_APP_AWS_USER_POOL=us-east-1_placeholder
REACT_APP_AWS_CLINET_ID=placeholder_client_id
REACT_APP_AWS_DOMAIN=placeholder.auth.us-east-1.amazoncognito.com
```

## Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run tests
- `npm run build:prod` - Build for production with production env

## Notes

- The app uses AWS Amplify for authentication (placeholder values are provided)
- Make sure the backend API is running on port 3001
- Node.js 16.20.2 is required due to dependency compatibility