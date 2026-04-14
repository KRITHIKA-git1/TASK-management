#!/bin/bash

# TaskFlow Complete Installation & Build Script
# This script installs dependencies, builds Docker images, and prepares for deployment

set -e

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-localhost}
IMAGE_TAG=${IMAGE_TAG:-latest}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  TaskFlow - Complete Installation${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check Prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node -v)${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker $(docker --version)${NC}"
echo ""

# Step 2: Install Dependencies
echo -e "${YELLOW}Step 2: Installing dependencies...${NC}"

echo "Installing backend dependencies..."
cd backend
npm install
cd ..
echo -e "${GREEN}✓ Backend dependencies installed${NC}"

echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
echo ""

# Step 3: Build Frontend
echo -e "${YELLOW}Step 3: Building frontend...${NC}"
cd frontend
npm run build
cd ..
echo -e "${GREEN}✓ Frontend built${NC}"
echo ""

# Step 4: Build Docker Images
echo -e "${YELLOW}Step 4: Building Docker images...${NC}"

echo "Building frontend image..."
cd frontend
docker build -t taskflow-frontend:$IMAGE_TAG .
docker tag taskflow-frontend:$IMAGE_TAG taskflow-frontend:latest
echo -e "${GREEN}✓ Frontend Docker image built${NC}"
cd ..

echo "Building backend image..."
cd backend
docker build -t taskflow-backend:$IMAGE_TAG .
docker tag taskflow-backend:$IMAGE_TAG taskflow-backend:latest
echo -e "${GREEN}✓ Backend Docker image built${NC}"
cd ..
echo ""

# Step 5: List Images
echo -e "${YELLOW}Step 5: Verifying Docker images...${NC}"
docker images | grep taskflow
echo ""

# Complete
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Test locally with Docker Compose:"
echo -e "   ${YELLOW}docker-compose up${NC}"
echo ""
echo "2. Deploy to Kubernetes:"
echo -e "   ${YELLOW}./deploy-k8s.sh${NC}"
echo ""
echo "3. Push to ECR for production:"
echo -e "   ${YELLOW}AWS_ACCOUNT_ID=YOUR_ID ./build-and-push.sh${NC}"
echo ""
