#!/bin/bash

# TaskFlow Local Setup Script - Automated Setup
# This script sets up the entire application for local development

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  TaskFlow Local Setup${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check Node.js
echo -e "${YELLOW}Step 1: Checking Node.js installation...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found. Please install Node.js 18+${NC}"
    echo "Download from: https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node -v)
echo -e "${GREEN}✓ Node.js installed: $NODE_VERSION${NC}"
echo ""

# Step 2: Setup Backend
echo -e "${YELLOW}Step 2: Setting up backend...${NC}"
cd backend
echo "Installing backend dependencies..."
npm install
echo "Creating .env file..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file (check and update if needed)${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi
cd ..
echo ""

# Step 3: Setup Frontend
echo -e "${YELLOW}Step 3: Setting up frontend...${NC}"
cd frontend
echo "Installing frontend dependencies..."
npm install
echo "Creating .env file..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi
cd ..
echo ""

# Step 4: Check MongoDB
echo -e "${YELLOW}Step 4: Checking MongoDB...${NC}"
if command -v mongosh &> /dev/null; then
    echo -e "${GREEN}✓ MongoDB client installed${NC}"
    if mongosh localhost:27017 --eval "db.version()" &> /dev/null; then
        echo -e "${GREEN}✓ MongoDB server running locally${NC}"
    else
        echo -e "${YELLOW}⚠ MongoDB server not running locally${NC}"
        echo "You can start it with Docker:"
        echo "  docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7"
    fi
else
    echo -e "${YELLOW}⚠ MongoDB client not found (optional)${NC}"
    echo "Install from: https://www.mongodb.com/try/download/shell"
    echo "Or use Docker: docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7"
fi
echo ""

# Complete
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}To start the application:${NC}"
echo ""
echo "Terminal 1 - Start MongoDB (if not running):"
echo -e "  ${BLUE}docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7${NC}"
echo ""
echo "Terminal 2 - Start Backend:"
echo -e "  ${BLUE}cd backend${NC}"
echo -e "  ${BLUE}npm start${NC}"
echo ""
echo "Terminal 3 - Start Frontend:"
echo -e "  ${BLUE}cd frontend${NC}"
echo -e "  ${BLUE}npm start${NC}"
echo ""
echo "Then open: http://localhost:3000"
echo ""
