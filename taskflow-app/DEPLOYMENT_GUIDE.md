# 🚀 TaskFlow - Complete Deployment Guide

## 📋 Table of Contents
1. [Local Development Setup](#local-development-setup)
2. [Docker Build Commands](#docker-build-commands)
3. [Amazon ECR Push Commands](#amazon-ecr-push-commands)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [Verification & Troubleshooting](#verification--troubleshooting)

---

## 🖥️ Local Development Setup

### Option A: Manual Setup (Recommended for Development)

```bash
# 1. Install dependencies for backend
cd backend
npm install
cp .env.example .env
# Edit .env if needed, default MongoDB is localhost:27017

# 2. Start backend (keep terminal open)
npm start
# Backend will run on http://localhost:5000

# 3. In a new terminal, install frontend dependencies
cd frontend
npm install
cp .env.example .env
# Edit .env if needed, API URL should be http://localhost:5000

# 4. Start frontend (keep terminal open)
npm start
# Frontend will run on http://localhost:3000
```

### Option B: Using Setup Script

```bash
# Linux/Mac
bash setup-local.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File setup-local.ps1
```

### Option C: MongoDB Setup (if not running locally)

```bash
# Using Docker (recommended)
docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7

# Verify MongoDB is running
mongosh localhost:27017
```

---

## 🐳 Docker Build Commands

### Build Individual Images

```bash
# Build Frontend Image
cd frontend
docker build -t taskflow-frontend:latest .
cd ..

# Build Backend Image
cd backend
docker build -t taskflow-backend:latest .
cd ..

# Build Both
docker build -f frontend/Dockerfile -t taskflow-frontend:latest .
docker build -f backend/Dockerfile -t taskflow-backend:latest .
```

### Test Images Locally

```bash
# Test Frontend
docker run -p 8080:80 taskflow-frontend:latest
# Access at http://localhost:8080

# Test Backend
docker run -p 5000:5000 \
  -e MONGODB_URI=mongodb://host.docker.internal:27017/taskflow \
  taskflow-backend:latest
# Access at http://localhost:5000/health

# Test with Docker Compose (All-in-one)
docker-compose up --build
# Access frontend at http://localhost
```

---

## ☁️ Amazon ECR Push Commands

### Step 1: Create ECR Repositories (One-time)

```bash
# Set variables
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create ECR repositories
aws ecr create-repository --repository-name taskflow-frontend --region $AWS_REGION
aws ecr create-repository --repository-name taskflow-backend --region $AWS_REGION

# Verify repositories created
aws ecr describe-repositories --region $AWS_REGION
```

### Step 2: Build and Push Images

#### Option A: Using provided script (Recommended)

```bash
# Linux/Mac
export AWS_ACCOUNT_ID=YOUR_ACCOUNT_ID
export AWS_REGION=us-east-1
bash build-and-push.sh

# Windows PowerShell
.\build-and-push.ps1 -AwsAccountId YOUR_ACCOUNT_ID -AwsRegion us-east-1
```

#### Option B: Manual Push

```bash
# Set variables
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID
export ECR_REGISTRY=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and tag frontend
cd frontend
docker build -t taskflow-frontend:latest .
docker tag taskflow-frontend:latest $ECR_REGISTRY/taskflow-frontend:latest
docker push $ECR_REGISTRY/taskflow-frontend:latest
cd ..

# Build and tag backend
cd backend
docker build -t taskflow-backend:latest .
docker tag taskflow-backend:latest $ECR_REGISTRY/taskflow-backend:latest
docker push $ECR_REGISTRY/taskflow-backend:latest
cd ..
```

### Step 3: Verify Images in ECR

```bash
# List all images
aws ecr describe-images \
  --repository-name taskflow-frontend \
  --region $AWS_REGION

aws ecr describe-images \
  --repository-name taskflow-backend \
  --region $AWS_REGION

# Get image URI
aws ecr describe-images \
  --repository-name taskflow-frontend \
  --query 'imageDetails[0].imageUri' \
  --region $AWS_REGION
```

---

## ☸️ Kubernetes Deployment

### Prerequisites

```bash
# Install kubectl
# macOS: brew install kubectl
# Windows: choco install kubernetes-cli
# Linux: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Verify kubectl is installed and connected
kubectl cluster-info
kubectl config current-context
```

### Step 1: Update Kubernetes Manifests

Before deploying, update the image URIs in the Kubernetes manifests:

```bash
# Get your image URIs
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=YOUR_ACCOUNT_ID

# Option 1: Automatic (Linux/Mac)
sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" kubernetes/backend-deployment.yaml
sed -i "s/<AWS_REGION>/$AWS_REGION/g" kubernetes/backend-deployment.yaml
sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" kubernetes/frontend-deployment.yaml
sed -i "s/<AWS_REGION>/$AWS_REGION/g" kubernetes/frontend-deployment.yaml

# Option 2: Manual (All platforms)
# Edit kubernetes/backend-deployment.yaml and kubernetes/frontend-deployment.yaml
# Replace <AWS_ACCOUNT_ID> with your account ID
# Replace <AWS_REGION> with your region (e.g., us-east-1)
# Example URI: 123456789.dkr.ecr.us-east-1.amazonaws.com/taskflow-backend:latest
```

### Step 2: Deploy Using Script (Recommended)

```bash
# Linux/Mac
bash deploy-k8s.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File deploy-k8s.ps1
```

### Step 3: Manual Deployment

```bash
# Create namespace and ConfigMaps
kubectl apply -f kubernetes/namespace-configmap.yaml

# Deploy MongoDB (wait for it to be ready)
kubectl apply -f kubernetes/mongodb-deployment.yaml
kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=300s

# Deploy Backend (wait for it to be ready)
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl wait --for=condition=ready pod -l app=backend -n taskflow --timeout=300s

# Deploy Frontend (wait for it to be ready)
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=300s

# Deploy HPA (Horizontal Pod Autoscaler)
kubectl apply -f kubernetes/hpa.yaml
```

### Step 4: Get Access URL

```bash
# Get the LoadBalancer external IP
kubectl get service frontend-service -n taskflow

# Watch for the external IP to be assigned
kubectl get service -w -n taskflow

# Once you have the IP, access the app
# http://<EXTERNAL-IP>

# For port-forwarding (if LoadBalancer IP is stuck on pending)
kubectl port-forward svc/frontend-service 8080:80 -n taskflow
# Then access: http://localhost:8080
```

---

## ✅ Verification & Troubleshooting

### Verify Deployments

```bash
# Check all pods
kubectl get pods -n taskflow

# Check pod status in detail
kubectl describe pod <pod-name> -n taskflow

# Check pod logs
kubectl logs -f <pod-name> -n taskflow

# Check services and LoadBalancer
kubectl get services -n taskflow

# Check deployment status
kubectl get deployments -n taskflow

# Check HPA status
kubectl get hpa -n taskflow

# Check events
kubectl get events -n taskflow --sort-by='.lastTimestamp'
```

### Test Backend API

```bash
# Get backend pod name
BACKEND_POD=$(kubectl get pod -l app=backend -n taskflow -o jsonpath='{.items[0].metadata.name}')

# Test health endpoint
kubectl exec -it $BACKEND_POD -n taskflow -- curl http://localhost:5000/health

# Test GET /tasks
kubectl exec -it $BACKEND_POD -n taskflow -- curl http://localhost:5000/tasks

# For port-forward testing
kubectl port-forward svc/backend-service 5000:5000 -n taskflow
curl http://localhost:5000/health
```

### Test Frontend

```bash
# Get frontend pod name
FRONTEND_POD=$(kubectl get pod -l app=frontend -n taskflow -o jsonpath='{.items[0].metadata.name}')

# Check if nginx is running
kubectl exec -it $FRONTEND_POD -n taskflow -- ps aux | grep nginx

# View nginx error logs
kubectl logs $FRONTEND_POD -n taskflow
```

### Common Issues & Solutions

#### Issue 1: Pods stuck in Pending

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check resource availability
kubectl describe node | grep "Allocated resources" -A 5

# Solution: May need to add more nodes or increase cluster resources
```

#### Issue 2: ImagePullBackOff Error

```bash
# Check if images exist in ECR
aws ecr describe-images --repository-name taskflow-backend

# Check if EKS has credentials to pull from ECR
# Create docker-registry secret if needed
kubectl create secret docker-registry ecr-secret \
  --docker-server=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region $AWS_REGION) \
  -n taskflow

# Add secret to deployment spec:
# imagePullSecrets:
# - name: ecr-secret
```

#### Issue 3: MongoDB connection failing

```bash
# Check MongoDB pod status
kubectl get pod -l app=mongodb -n taskflow
kubectl logs -f -l app=mongodb -n taskflow

# Test MongoDB connectivity from backend pod
BACKEND_POD=$(kubectl get pod -l app=backend -n taskflow -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $BACKEND_POD -n taskflow -- \
  mongosh mongodb://mongodb-service:27017/taskflow

# Check MONGODB_URI env variable
kubectl exec -it $BACKEND_POD -n taskflow -- env | grep MONGODB
```

#### Issue 4: Frontend cannot reach backend

```bash
# Check if services are accessible
kubectl get service -n taskflow

# Test backend service DNS resolution
kubectl exec -it <frontend-pod> -n taskflow -- nslookup backend-service

# Test backend connectivity from frontend pod
kubectl exec -it <frontend-pod> -n taskflow -- curl http://backend-service:5000/health

# Check ConfigMap values
kubectl get configmap backend-config -n taskflow -o yaml
kubectl get configmap frontend-config -n taskflow -o yaml
```

---

## 📊 Scaling & Management

### Manual Scaling

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3 -n taskflow

# Scale frontend to 4 replicas
kubectl scale deployment frontend --replicas=4 -n taskflow

# Verify scaling
kubectl get pods -n taskflow -l app=backend
```

### Update Deployment

```bash
# Push new image to ECR
docker push $ECR_REGISTRY/taskflow-backend:latest

# Restart pods to pull new image
kubectl rollout restart deployment/backend -n taskflow

# Monitor rollout
kubectl rollout status deployment/backend -n taskflow
```

### View Metrics (if metrics-server installed)

```bash
# Check pod resource usage
kubectl top pods -n taskflow

# Check node resource usage
kubectl top nodes
```

---

## 🧹 Cleanup

### Delete Kubernetes Resources

```bash
# Delete entire namespace (deletes all resources)
kubectl delete namespace taskflow

# Or delete individual resources
kubectl delete deployment -n taskflow --all
kubectl delete service -n taskflow --all
kubectl delete pvc -n taskflow --all

# Verify deletion
kubectl get namespace taskflow  # Should show NotFound
```

### Clean Docker Images

```bash
# Remove local images
docker rmi taskflow-frontend:latest
docker rmi taskflow-backend:latest

# Remove ECR images
aws ecr batch-delete-image \
  --repository-name taskflow-frontend \
  --image-ids imageTag=latest \
  --region $AWS_REGION

aws ecr batch-delete-image \
  --repository-name taskflow-backend \
  --image-ids imageTag=latest \
  --region $AWS_REGION
```

---

## 📞 Support

For detailed information, see:
- [README.md](README.md) - Complete documentation
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Project layout

---

**Happy Deploying! 🎉**
