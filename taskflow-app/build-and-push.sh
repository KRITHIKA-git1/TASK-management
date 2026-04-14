#!/bin/bash

# TaskFlow Docker Build and Push Script
# This script builds Docker images and pushes them to Amazon ECR

set -e

# Configuration
AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-}
IMAGE_TAG=${IMAGE_TAG:-latest}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}Error: AWS_ACCOUNT_ID not set${NC}"
    echo "Usage: AWS_ACCOUNT_ID=123456789 AWS_REGION=us-east-1 ./build-and-push.sh"
    exit 1
fi

ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo -e "${YELLOW}TaskFlow Docker Build & Push${NC}"
echo "AWS Region: $AWS_REGION"
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "ECR Registry: $ECR_REGISTRY"
echo ""

# Login to ECR
echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
echo -e "${GREEN}✓ ECR login successful${NC}"

# Build and push frontend
echo ""
echo -e "${YELLOW}Building frontend image...${NC}"
cd frontend
docker build -t taskflow-frontend:$IMAGE_TAG .
docker tag taskflow-frontend:$IMAGE_TAG $ECR_REGISTRY/taskflow-frontend:$IMAGE_TAG
echo -e "${GREEN}✓ Frontend image built${NC}"

echo -e "${YELLOW}Pushing frontend to ECR...${NC}"
docker push $ECR_REGISTRY/taskflow-frontend:$IMAGE_TAG
echo -e "${GREEN}✓ Frontend pushed to ECR${NC}"
cd ..

# Build and push backend
echo ""
echo -e "${YELLOW}Building backend image...${NC}"
cd backend
docker build -t taskflow-backend:$IMAGE_TAG .
docker tag taskflow-backend:$IMAGE_TAG $ECR_REGISTRY/taskflow-backend:$IMAGE_TAG
echo -e "${GREEN}✓ Backend image built${NC}"

echo -e "${YELLOW}Pushing backend to ECR...${NC}"
docker push $ECR_REGISTRY/taskflow-backend:$IMAGE_TAG
echo -e "${GREEN}✓ Backend pushed to ECR${NC}"
cd ..

echo ""
echo -e "${GREEN}=== Build & Push Complete ===${NC}"
echo ""
echo "Frontend: $ECR_REGISTRY/taskflow-frontend:$IMAGE_TAG"
echo "Backend: $ECR_REGISTRY/taskflow-backend:$IMAGE_TAG"
echo ""
echo "Next steps:"
echo "1. Update kubernetes/backend-deployment.yaml with new image URI"
echo "2. Update kubernetes/frontend-deployment.yaml with new image URI"
echo "3. Run: kubectl apply -f kubernetes/"
