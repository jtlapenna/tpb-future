# Quick Start Guide

## 🚀 For New Developers

### What's Working
✅ **App is fully functional** - Both frontend and backend running  
✅ **Node.js compatibility fixed** - Works with Node.js 16.20.2  
✅ **Sass compilation fixed** - Replaced node-sass with sass  
✅ **All dependencies installed** - No missing packages  
✅ **Environment configured** - .env files created automatically  
✅ **Missing files created** - public/index.html and manifest.json  

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

**What the script does:**
- ✅ Starts backend server (NestJS API)
- ✅ Starts frontend server (React app)
- ✅ Creates `.env` file automatically if missing
- ✅ Uses Node.js compatibility fix for webpack
- ✅ Uses sass instead of node-sass for compilation
- ✅ Runs both servers in background with logs

### Manual Start (if needed)

**Terminal 1 - Backend:**
```bash
cd ThePeakBeyond_eCommerce_API
npm run start:dev
```

**Terminal 2 - Frontend:**
```bash
cd ThePeakBeyond_eCommerce
export NODE_OPTIONS="--openssl-legacy-provider"
npm start
```

### Access Points
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:3001
- **API Docs**: http://localhost:3001/api

### Key Files Created
- `ThePeakBeyond_eCommerce/.env` - Frontend environment variables
- `ThePeakBeyond_eCommerce/public/index.html` - React app entry point
- `ThePeakBeyond_eCommerce/public/manifest.json` - App manifest

### Troubleshooting
- **"node-sass build failed"** → Fixed! Now uses sass instead of node-sass
- **"env-cmd: command not found"** → Run `npm install` in frontend
- **"Failed to find .env file"** → Setup script creates this automatically
- **"digital envelope routines::unsupported"** → Script uses --openssl-legacy-provider

The app is ready for development! 🎉
