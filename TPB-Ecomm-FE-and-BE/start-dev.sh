#!/bin/bash

# The Peak Beyond E-commerce V2 - Development Startup Script
# This script helps you get the development environment running quickly

echo "🚀 Starting The Peak Beyond E-commerce V2 Development Environment"
echo "================================================================"

# Check if we're in the right directory
if [ ! -d "ThePeakBeyond_eCommerce_API" ] || [ ! -d "ThePeakBeyond_eCommerce" ]; then
    echo "❌ Error: Please run this script from the TPB-Ecomm-FE-and-BE directory"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed. Please install Node.js 14.x or higher"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed. Please install npm"
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Check if PostgreSQL is running
if ! pg_isready -q; then
    echo "⚠️  Warning: PostgreSQL doesn't appear to be running"
    echo "   Please start PostgreSQL before continuing"
    echo "   macOS: brew services start postgresql"
    echo "   Linux: sudo systemctl start postgresql"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "ThePeakBeyond_eCommerce_API/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd ThePeakBeyond_eCommerce_API
    npm install
    cd ..
fi

if [ ! -d "ThePeakBeyond_eCommerce/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    cd ThePeakBeyond_eCommerce
    npm install
    cd ..
fi

# Check for environment files
if [ ! -f "ThePeakBeyond_eCommerce_API/.env" ]; then
    echo "⚠️  Warning: Backend .env file not found"
    echo "   Please create ThePeakBeyond_eCommerce_API/.env with your configuration"
    echo "   See LOCAL_DEVELOPMENT.md for details"
fi

if [ ! -f "ThePeakBeyond_eCommerce/.env" ]; then
    echo "⚠️  Warning: Frontend .env file not found"
    echo "   Please create ThePeakBeyond_eCommerce/.env with your configuration"
    echo "   See LOCAL_DEVELOPMENT.md for details"
fi

echo ""
echo "🎯 Ready to start development servers!"
echo ""
echo "To start the applications:"
echo "1. Backend:  cd ThePeakBeyond_eCommerce_API && npm run start:dev"
echo "2. Frontend: cd ThePeakBeyond_eCommerce && npm start"
echo ""
echo "Access points:"
echo "- Frontend: http://localhost:3000"
echo "- Backend:  http://localhost:3001"
echo "- API Docs: http://localhost:3001/api"
echo ""
echo "📚 For detailed setup instructions, see:"
echo "- SETUP_GUIDE.md"
echo "- LOCAL_DEVELOPMENT.md"
echo ""
echo "Happy coding! 🎉"
