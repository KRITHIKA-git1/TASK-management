# TaskFlow - Containerized Task Management Application

Welcome to **TaskFlow**, a full-stack web application for managing tasks efficiently with containerization and Kubernetes deployment support.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Local Development](#local-development)
- [Docker Build Commands](#docker-build-commands)
- [Amazon ECR Deployment](#amazon-ecr-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [API Endpoints](#api-endpoints)
- [Troubleshooting](#troubleshooting)

## 🎯 Project Overview

TaskFlow is a beginner-friendly full-stack application built with:
- **Frontend**: React with a modern, responsive UI
- **Backend**: Node.js with Express REST APIs
- **Database**: MongoDB for data persistence
- **Containerization**: Docker for consistent deployments
- **Orchestration**: Kubernetes for scalable deployments

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    TaskFlow Application                 │
├─────────────────────────────────────────────────────────┤
│  Frontend (React)  │ Backend (Node.js) │ Database (DB) │
│  - UI Components   │ - REST APIs       │ - MongoDB     │
│  - Task Management │ - Business Logic  │ - Data Store  │
├─────────────────────────────────────────────────────────┤
│        Docker Containers + Kubernetes Orchestration      │
└─────────────────────────────────────────────────────────┘
```

## 📦 Prerequisites

### For Local Development
- Node.js 18+ and npm
- Docker and Docker Compose
- MongoDB (optional, if using Docker Compose it's included)

### For Kubernetes Deployment
- Kubernetes cluster (1.21+)
- kubectl installed and configured
- Docker for building images
- AWS Account (for ECR)
- AWS CLI configured

## 📁 Project Structure

```
taskflow-app/
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── TaskForm.js
│   │   │   ├── TaskForm.css
│   │   │   ├── TaskList.js
│   │   │   ├── TaskList.css
│   │   │   ├── TaskItem.js
│   │   │   └── TaskItem.css
│   │   ├── App.js
│   │   ├── App.css
│   │   ├── index.js
│   │   └── index.css
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── .env.example
├── backend/
│   ├── models/
│   │   └── Task.js
│   ├── routes/
│   │   └── tasks.js
│   ├── config/
│   │   └── database.js
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── .env.example
├── kubernetes/
│   ├── namespace-configmap.yaml
│   ├── mongodb-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   └── hpa.yaml
├── docker-compose.yml
└── README.md
```

## 🚀 Local Development

### 1. Setup Frontend

```bash
cd frontend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Start development server (runs on http://localhost:3000)
npm start
```

### 2. Setup Backend

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Start backend server (runs on http://localhost:5000)
npm start

# For development with auto-reload
npm run dev
```

### 3. Setup MongoDB

For local development, install MongoDB or use Docker:

```bash
# Using Docker
docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7
```

### Alternative: Using Docker Compose

```bash
# From the root directory
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🐳 Docker Build Commands

### Build Frontend Image

```bash
cd frontend

# Build image
docker build -t taskflow-frontend:latest .

# Run container
docker run -p 80:80 taskflow-frontend:latest

# Access at http://localhost
```

### Build Backend Image

```bash
cd backend

# Build image
docker build -t taskflow-backend:latest .

# Run container
docker run -p 5000:5000 \
  -e MONGODB_URI=mongodb://host.docker.internal:27017/taskflow \
  taskflow-backend:latest

# Access at http://localhost:5000
```

### Using Docker Compose

```bash
# Build and start all services
docker-compose up --build

# View logs
docker-compose logs -f backend

# Stop all services
docker-compose down

# Remove volumes (clean database)
docker-compose down -v
```

## 🔒 Amazon ECR Deployment

### Prerequisites

1. Create AWS Account and configure AWS CLI:
```bash
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Region, Output format
```

2. Create ECR repositories:
```bash
# Set your AWS region and account ID
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create repositories
aws ecr create-repository \
  --repository-name taskflow-frontend \
  --region $AWS_REGION

aws ecr create-repository \
  --repository-name taskflow-backend \
  --region $AWS_REGION
```

### Build and Push Images

```bash
# Set variables
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID
export ECR_REGISTRY=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and tag frontend image
cd frontend
docker build -t taskflow-frontend:latest .
docker tag taskflow-frontend:latest $ECR_REGISTRY/taskflow-frontend:latest
docker push $ECR_REGISTRY/taskflow-frontend:latest

# Build and tag backend image
cd ../backend
docker build -t taskflow-backend:latest .
docker tag taskflow-backend:latest $ECR_REGISTRY/taskflow-backend:latest
docker push $ECR_REGISTRY/taskflow-backend:latest
```

### Verify Images in ECR

```bash
# List frontend images
aws ecr describe-images --repository-name taskflow-frontend --region $AWS_REGION

# List backend images
aws ecr describe-images --repository-name taskflow-backend --region $AWS_REGION
```

## ☸️ Kubernetes Deployment

### 1. Update Kubernetes Manifests

Before deploying, update the image URIs in the manifest files:

```bash
# Set your AWS details
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID

# Update backend deployment
sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" kubernetes/backend-deployment.yaml
sed -i "s/<AWS_REGION>/$AWS_REGION/g" kubernetes/backend-deployment.yaml

# Update frontend deployment
sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" kubernetes/frontend-deployment.yaml
sed -i "s/<AWS_REGION>/$AWS_REGION/g" kubernetes/frontend-deployment.yaml

# For Windows PowerShell:
# Use the provided .env.example files to manually update the image URIs
```

### 2. Deploy to Kubernetes

```bash
# Create namespace and ConfigMaps
kubectl apply -f kubernetes/namespace-configmap.yaml

# Deploy MongoDB
kubectl apply -f kubernetes/mongodb-deployment.yaml

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=300s

# Deploy Backend
kubectl apply -f kubernetes/backend-deployment.yaml

# Wait for Backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n taskflow --timeout=300s

# Deploy Frontend
kubectl apply -f kubernetes/frontend-deployment.yaml

# Deploy Horizontal Pod Autoscaler
kubectl apply -f kubernetes/hpa.yaml

# Wait for Frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=300s
```

### 3. Check Deployment Status

```bash
# List all pods
kubectl get pods -n taskflow

# List all services
kubectl get services -n taskflow

# Get detailed pod information
kubectl describe pod <pod-name> -n taskflow

# View logs
kubectl logs -f <pod-name> -n taskflow

# Get LoadBalancer IP
kubectl get service frontend-service -n taskflow

# Watch deployments
kubectl rollout status deployment/frontend -n taskflow
kubectl rollout status deployment/backend -n taskflow
kubectl rollout status deployment/mongodb -n taskflow
```

### 4. Access the Application

```bash
# Get the external IP of the LoadBalancer
kubectl get service frontend-service -n taskflow

# The output will show:
# frontend-service   LoadBalancer   10.0.0.1   <EXTERNAL-IP>   80:30123/TCP
# Access the app via: http://<EXTERNAL-IP>
```

### 5. Scale Deployments Manually

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3 -n taskflow

# Scale frontend to 4 replicas
kubectl scale deployment frontend --replicas=4 -n taskflow

# Check HPA status
kubectl get hpa -n taskflow
```

## 🔗 API Endpoints

### Base URL: `http://localhost:5000` (local) or `http://backend-service:5000` (Kubernetes)

### Endpoints

#### 1. Health Check
```bash
GET /health
# Response: {"status":"OK","message":"TaskFlow backend is running"}
```

#### 2. Get All Tasks
```bash
GET /tasks

# Response:
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "title": "Complete project",
    "completed": false,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
]
```

#### 3. Create New Task
```bash
POST /tasks

# Request body:
{
  "title": "New task title"
}

# Response:
{
  "_id": "507f1f77bcf86cd799439012",
  "title": "New task title",
  "completed": false,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

#### 4. Delete Task
```bash
DELETE /tasks/:id

# Response:
{
  "message": "Task deleted successfully",
  "task": {...}
}
```

## 📊 Features

### Frontend Features
- ✅ Add new tasks
- ✅ View all tasks
- ✅ Delete tasks
- ✅ Responsive design
- ✅ Real-time updates
- ✅ Error handling

### Backend Features
- ✅ RESTful API
- ✅ MongoDB integration
- ✅ CORS support
- ✅ Health checks
- ✅ Error handling
- ✅ Request validation

### DevOps Features
- ✅ Docker containerization
- ✅ Kubernetes deployment
- ✅ Horizontal Pod Autoscaling
- ✅ Health probes (liveness, readiness)
- ✅ Persistent volume for MongoDB
- ✅ Resource limits and requests

## 🔧 Troubleshooting

### Frontend Issues

**Issue: "Cannot connect to backend"**
```bash
# Check if backend is running
curl http://localhost:5000/health

# Check frontend environment variable
cat frontend/.env
# REACT_APP_API_URL should be correct

# Rebuild frontend with correct API URL
npm run build
```

**Issue: React app not loading**
```bash
# Clear node modules and reinstall
rm -rf node_modules
npm install
npm start
```

### Backend Issues

**Issue: "MongoDB connection failed"**
```bash
# Check MongoDB is running
# Local: mongosh localhost:27017
# Docker: docker ps | grep mongodb

# Check MONGODB_URI in .env
cat backend/.env

#  Check connection string format
# mongodb://localhost:27017/taskflow (local)
# mongodb://mongodb-service:27017/taskflow (Kubernetes)
```

**Issue: "Port already in use"**
```bash
# Find process using port
lsof -i :5000  # macOS/Linux
netstat -ano | findstr :5000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

### Kubernetes Issues

**Issue: Pods not running**
```bash
# Check pod status
kubectl describe pod <pod-name> -n taskflow

# Check events
kubectl get events -n taskflow

# Check logs
kubectl logs <pod-name> -n taskflow
```

**Issue: Cannot access frontend**
```bash
# Check service
kubectl get service frontend-service -n taskflow

# Check if LoadBalancer has external IP (wait a few minutes on cloud providers)
kubectl get service -w -n taskflow

# Port forward for testing
kubectl port-forward svc/frontend-service 8080:80 -n taskflow
# Access at http://localhost:8080
```

## 🧹 Cleanup

### Local Docker Cleanup
```bash
# Stop containers
docker-compose down

# Remove images
docker rmi taskflow-frontend taskflow-backend

# Remove volumes
docker volume rm taskflow_app_mongodb_data
```

### Kubernetes Cleanup
```bash
# Delete all taskflow resources
kubectl delete namespace taskflow

# Verify deletion
kubectl get namespaces
```

## 📚 Additional Resources

- [React Documentation](https://react.dev)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)

## 📝 License

This project is open source and available for educational purposes.

---

**Happy Task Managing! 🎉**
