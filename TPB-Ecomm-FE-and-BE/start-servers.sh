#!/bin/bash

# The Peak Beyond E-commerce V2 - Server Startup Script
# This script starts both backend and frontend servers

echo "🚀 Starting The Peak Beyond E-commerce V2 Servers"
echo "================================================"

# Check if we're in the right directory
if [ ! -d "ThePeakBeyond_eCommerce_API" ] || [ ! -d "ThePeakBeyond_eCommerce" ]; then
    echo "❌ Error: Please run this script from the TPB-Ecomm-FE-and-BE directory"
    exit 1
fi

# Switch to Node.js 16.20.2 if nvm is available
if command -v nvm &> /dev/null; then
    echo "📦 Switching to Node.js 16.20.2..."
    nvm use 16.20.2
else
    echo "⚠️  nvm not found. Using current Node.js version"
fi

# Create .env file if it doesn't exist
if [ ! -f "ThePeakBeyond_eCommerce/.env" ]; then
    echo "📝 Creating .env file..."
    cat > ThePeakBeyond_eCommerce/.env << 'EOF'
REACT_APP_API_URL=http://localhost:3001
REACT_APP_AWS_REGION=us-east-1
REACT_APP_AWS_USER_POOL=us-east-1_placeholder
REACT_APP_AWS_CLINET_ID=placeholder_client_id
REACT_APP_AWS_DOMAIN=placeholder.auth.us-east-1.amazoncognito.com
EOF
fi

echo "🔧 Starting backend server..."
cd ThePeakBeyond_eCommerce_API
npm run start:dev > ../backend.log 2>&1 &
BACKEND_PID=$!

echo "⏳ Waiting for backend to start..."
sleep 5

echo "🎨 Starting frontend server..."
cd ../ThePeakBeyond_eCommerce
# Use legacy OpenSSL provider for Node.js v22+ compatibility
export NODE_OPTIONS="--openssl-legacy-provider"
npm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!

echo ""
echo "✅ Servers are starting!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔌 Backend: http://localhost:3001"
echo "📚 API Docs: http://localhost:3001/api"
echo ""
echo "📋 Process IDs:"
echo "   Backend PID: $BACKEND_PID"
echo "   Frontend PID: $FRONTEND_PID"
echo ""
echo "📄 Logs:"
echo "   Backend: backend.log"
echo "   Frontend: frontend.log"
echo ""
echo "🛑 To stop servers: kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "⏳ Waiting for servers to fully start..."
sleep 15

echo "🎉 Servers should be running now!"
echo "Visit http://localhost:3000 to see the app"
