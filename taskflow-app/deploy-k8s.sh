#!/bin/bash

# TaskFlow Kubernetes Deployment Script
# This script deploys TaskFlow to Kubernetes cluster

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  TaskFlow Kubernetes Deployment${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check cluster connection
echo -e "${BLUE}Checking Kubernetes cluster...${NC}"
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
else
    echo -e "${RED}✗ Not connected to Kubernetes cluster${NC}"
    echo "Please configure kubectl or connect to your cluster"
    exit 1
fi

echo ""
echo -e "${BLUE}Current Context:${NC} $(kubectl config current-context)"
echo ""

# Step 1: Create namespace and ConfigMaps
echo -e "${YELLOW}Step 1: Creating namespace and ConfigMaps...${NC}"
kubectl apply -f kubernetes/namespace-configmap.yaml
echo -e "${GREEN}✓ Namespace and ConfigMaps created${NC}"

# Step 2: Deploy MongoDB
echo ""
echo -e "${YELLOW}Step 2: Deploying MongoDB...${NC}"
kubectl apply -f kubernetes/mongodb-deployment.yaml
echo -e "${GREEN}✓ MongoDB deployment created${NC}"

echo -e "${YELLOW}Waiting for MongoDB to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=300s 2>/dev/null || {
    echo -e "${RED}MongoDB is taking longer to start. You can check status with:${NC}"
    echo "kubectl get pods -n taskflow"
    echo "kubectl logs -f -l app=mongodb -n taskflow"
}
echo -e "${GREEN}✓ MongoDB is ready${NC}"

# Step 3: Deploy Backend
echo ""
echo -e "${YELLOW}Step 3: Deploying Backend...${NC}"
kubectl apply -f kubernetes/backend-deployment.yaml
echo -e "${GREEN}✓ Backend deployment created${NC}"

echo -e "${YELLOW}Waiting for Backend to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=backend -n taskflow --timeout=300s 2>/dev/null || {
    echo -e "${RED}Backend is taking longer to start. Check status with:${NC}"
    echo "kubectl get pods -n taskflow"
    echo "kubectl logs -f -l app=backend -n taskflow"
}
echo -e "${GREEN}✓ Backend is ready${NC}"

# Step 4: Deploy Frontend
echo ""
echo -e "${YELLOW}Step 4: Deploying Frontend...${NC}"
kubectl apply -f kubernetes/frontend-deployment.yaml
echo -e "${GREEN}✓ Frontend deployment created${NC}"

echo -e "${YELLOW}Waiting for Frontend to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=300s 2>/dev/null || {
    echo -e "${RED}Frontend is taking longer to start. Check status with:${NC}"
    echo "kubectl get pods -n taskflow"
    echo "kubectl logs -f -l app=frontend -n taskflow"
}
echo -e "${GREEN}✓ Frontend is ready${NC}"

# Step 5: Deploy HPA
echo ""
echo -e "${YELLOW}Step 5: Deploying Horizontal Pod Autoscaler...${NC}"
kubectl apply -f kubernetes/hpa.yaml
echo -e "${GREEN}✓ HPA deployed${NC}"

# Deployment complete
echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""

# Get service information
echo -e "${BLUE}Deployment Status:${NC}"
echo ""
kubectl get all -n taskflow
echo ""

# Get LoadBalancer IP
echo -e "${BLUE}Getting LoadBalancer IP...${NC}"
FRONTEND_IP=$(kubectl get service frontend-service -n taskflow -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

if [ "$FRONTEND_IP" == "pending" ] || [ -z "$FRONTEND_IP" ]; then
    echo -e "${YELLOW}⏳ Frontend LoadBalancer IP is pending (can take a few minutes on cloud providers)${NC}"
    echo ""
    echo "To get the external IP, run:"
    echo ""
    echo -e "${BLUE}kubectl get service frontend-service -n taskflow${NC}"
    echo ""
    echo "Or watch for updates:"
    echo ""
    echo -e "${BLUE}kubectl get service -w -n taskflow${NC}"
else
    echo -e "${GREEN}✓ Frontend accessible at: http://$FRONTEND_IP${NC}"
fi

echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo ""
echo "View pods:"
echo -e "  ${BLUE}kubectl get pods -n taskflow${NC}"
echo ""
echo "View logs:"
echo -e "  ${BLUE}kubectl logs -f <pod-name> -n taskflow${NC}"
echo ""
echo "Port forward to frontend:"
echo -e "  ${BLUE}kubectl port-forward svc/frontend-service 8080:80 -n taskflow${NC}"
echo ""
echo "Port forward to backend:"
echo -e "  ${BLUE}kubectl port-forward svc/backend-service 5000:5000 -n taskflow${NC}"
echo ""
echo "Delete deployment:"
echo -e "  ${BLUE}kubectl delete namespace taskflow${NC}"
