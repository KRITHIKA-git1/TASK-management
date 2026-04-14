# 🚀 TaskFlow Quick Start Guide

Welcome to TaskFlow! This guide will get you up and running in minutes.

## 🎯 Choose Your Path

### Option 1: Local Development (Fastest - 5 minutes)
Perfect for development and testing

**Prerequisites:**
- Node.js 18+ installed
- MongoDB running locally (or use Docker)

**Steps:**

```bash
# 1. Start MongoDB with Docker (optional)
docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7

# 2. Setup and run backend
cd backend
npm install
npm start
# Backend runs on http://localhost:5000

# 3. In another terminal, setup and run frontend
cd frontend
npm install
npm start
# Frontend runs on http://localhost:3000
```

**Access the app:** http://localhost:3000

---

### Option 2: Docker Compose (10 minutes)
Run everything with Docker containers

**Prerequisites:**
- Docker and Docker Compose installed

**Steps:**

```bash
# From the root directory
docker-compose up --build

# Wait for all services to start (check logs)
docker-compose logs -f
```

**Access the app:** http://localhost

**Stop services:**
```bash
docker-compose down
```

---

### Option 3: Kubernetes (30 minutes)
Deploy to a Kubernetes cluster

**Prerequisites:**
- kubectl installed and connected to a cluster
- Docker images built and pushed to ECR (or Docker Hub)

**Steps:**

```bash
# 1. Build and push images to ECR
AWS_ACCOUNT_ID=YOUR_ID AWS_REGION=us-east-1 ./build-and-push.sh

# 2. Update k8s manifests with your image URIs

# 3. Deploy
./deploy-k8s.sh
# Or on Windows:
# powershell -ExecutionPolicy Bypass -File deploy-k8s.ps1

# 4. Get the frontend URL
kubectl get service frontend-service -n taskflow
```

---

## 🔧 Quick Troubleshooting

### Port already in use?
```bash
# Kill process using port 3000 (macOS/Linux)
lsof -ti:3000 | xargs kill -9

# Kill process using port 3000 (Windows)
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Can't connect to MongoDB?
```bash
# Check if MongoDB is running
mongosh localhost:27017

# Or restart MongoDB container
docker stop taskflow-mongodb
docker rm taskflow-mongodb
docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7
```

### Dependencies installation issues?
```bash
# Clear npm cache and reinstall
cd backend  # or frontend
rm -rf node_modules package-lock.json
npm install
```

---

## 📱 Using the App

1. **Add a Task:** Type your task in the input field and click "Add Task"
2. **View Tasks:** All tasks appear in the list below
3. **Delete a Task:** Click the red "×" button on any task
4. **Track Progress:** Tasks show creation date and status

---

## 📚 Next Steps

- **Local testing:** Use Option 1 for development
- **Docker testing:** Use Option 2 to test containerization
- **Production deployment:** Use Option 3 for Kubernetes

For detailed information, see [README.md](README.md)

---

**Happy task managing! 🎉**
