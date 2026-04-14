# TaskFlow - System Architecture & Deployment Diagrams

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          END USERS                                       │
│                  (Web Browser / Client)                                  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │   LoadBalancer Service   │
                    │  (Frontend – Port 80)    │
                    └────────────┬──────────────┘
                                 │
         ┌───────────────────────┼──────────────────────┐
         │                       │                      │
    ┌────▼────┐            ┌─────▼──────┐         ┌────▼────┐
    │Frontend │            │ Frontend   │  ...    │Frontend │
    │Pod 1    │            │ Pod 2      │         │Pod N    │
    └────┬────┘            └─────┬──────┘         └────┬────┘
         │                       │                     │
         └───────────────────────┼─────────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │ Backend Service          │
                    │  (ClusterIP – Port 5000) │
                    └────────────┬──────────────┘
         ┌───────────────────────┼──────────────────────┐
         │                       │                      │
    ┌────▼────┐            ┌─────▼──────┐         ┌────▼────┐
    │Backend  │            │ Backend    │  ...    │Backend  │
    │Pod 1    │            │ Pod 2      │         │Pod N    │
    └────┬────┘            └─────┬──────┘         └────┬────┘
         │                       │                     │
         └───────────────────────┼─────────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │ MongoDB Service          │
                    │ (ClusterIP – Port 27017) │
                    └────────────┬──────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │  MongoDB Pod             │
                    │  + Persistent Volume     │
                    │  (5GB Storage PVC)       │
                    └──────────────────────────┘

Key: 
  ├─ Auto-scaling enabled via HPA
  ├─ Health checks on all pods
  ├─ ConfigMaps for configuration
  └─ Persistent data for MongoDB
```

---

## 🔄 Request Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER INTERACTION (Frontend)                                  │
│    ├─ User clicks "Add Task"                                    │
│    ├─ Input validated in React                                  │
│    └─ API call initiated (fetch)                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ 2. HTTP REQUEST                                                 │
│    POST /tasks                                                  │
│    Content-Type: application/json                               │
│    Body: { "title": "My Task" }                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ 3. BACKEND PROCESSING (Express)                                 │
│    ├─ Receive request at POST /tasks                            │
│    ├─ Validate input data                                       │
│    ├─ Create Task document                                      │
│    └─ Save to MongoDB                                           │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ 4. DATABASE OPERATION (MongoDB)                                 │
│    ├─ Connect to MongoDB                                        │
│    ├─ Insert new task document                                  │
│    ├─ Return saved document with _id                            │
│    └─ Commit to persistent storage                              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ 5. HTTP RESPONSE                                                │
│    Status: 201 Created                                          │
│    Body: { "_id": "...", "title": "My Task", ... }            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ 6. FRONTEND UPDATE (React)                                      │
│    ├─ Parse JSON response                                       │
│    ├─ Add task to state                                         │
│    ├─ Re-render task list                                       │
│    └─ Show success message                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Docker Multi-Stage Build (Frontend)

```
BUILD STAGE
┌─────────────────────────────────────★
│ FROM node:18-alpine
│ (Install dependencies)
│ npm install
│ npm run build
│ (Creates build/ folder ~50KB)
│ (Discard node_modules)
└─────────────────────────────────────┤
                                      │ Copy build folder only
                                      │
RUNTIME STAGE                         │
┌─────────────────────────────────────▼
│ FROM nginx:alpine
│ (Lightweight web server)
│ COPY build/ /usr/share/nginx/html
│ EXPOSE 80
│ CMD nginx
└─────────────────────────────────────★

Result: ~50MB image (optimized)
```

---

## 🚀 Deployment Pipeline

```
┌──────────────────────────────────────────────────────────────────┐
│ STEP 1: LOCAL DEVELOPMENT                                        │
│ ├─ git clone                                                     │
│ ├─ npm install                                                   │
│ ├─ npm start (dev server)                                       │
│ └─ Access: localhost:3000                                       │
└──────────────┬───────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────────┐
│ STEP 2: LOCAL DOCKER TEST                                        │
│ ├─ docker-compose up                                             │
│ ├─ Services: frontend, backend, mongodb                         │
│ ├─ Access: localhost                                            │
│ └─ Test: All features                                           │
└──────────────┬───────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────────┐
│ STEP 3: BUILD DOCKER IMAGES                                      │
│ ├─ docker build -f frontend/Dockerfile -t image:tag .           │
│ ├─ docker build -f backend/Dockerfile -t image:tag .            │
│ └─ Verify: docker images                                        │
└──────────────┬───────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────────┐
│ STEP 4: PUSH TO ECR                                              │
│ ├─ aws ecr get-login-password | docker login                    │
│ ├─ docker tag image:tag repo/image:tag                          │
│ ├─ docker push repo/image:tag                                   │
│ └─ Verify: aws ecr describe-images                              │
└──────────────┬───────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────────┐
│ STEP 5: DEPLOY TO KUBERNETES                                     │
│ ├─ kubectl apply -f kubernetes/namespace-configmap.yaml         │
│ ├─ kubectl apply -f kubernetes/mongodb-deployment.yaml          │
│ ├─ kubectl apply -f kubernetes/backend-deployment.yaml          │
│ ├─ kubectl apply -f kubernetes/frontend-deployment.yaml         │
│ ├─ kubectl apply -f kubernetes/hpa.yaml                         │
│ └─ Verify: kubectl get all -n taskflow                          │
└──────────────┬───────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────────┐
│ STEP 6: VERIFY & ACCESS                                          │
│ ├─ kubectl get service frontend-service -n taskflow             │
│ ├─ Get LoadBalancer IP/Hostname                                 │
│ ├─ Access: http://EXTERNAL-IP                                   │
│ └─ Test functionality                                           │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Kubernetes Auto-Scaling Flow

```
┌─────────────────────────────────────────────────────────────┐
│ HORIZONTAL POD AUTOSCALER (HPA)                             │
└────────────────────────────────┬────────────────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │ Monitor Pod Metrics      │
                    │ (CPU, Memory usage)      │
                    │ Every 15 seconds         │
                    └────────────┬──────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
    ┌────────────▼─────────┐      ┌──────────────▼─────────┐
    │ CPU < 70%            │      │ CPU > 70%              │
    │ Memory < Threshold   │      │ OR Memory > Threshold  │
    └────────────┬─────────┘      └──────────────┬─────────┘
                 │                               │
         ┌───────▼────────┐         ┌────────────▼──────────┐
         │ Current Replicas        │ Scale UP             │
         │ = Minimum (2)           │ Add 1 Pod            │
         │                         │ Max 5 Replicas       │
         └────────────────┘        └─────────────────────┘
              OR                            │
         ┌───────▼────────┐         ┌───────▼──────────┐
         │ All pods low    │        │ More resources   │
         │ for 5 min       │        │ available        │
         └────────────────┘        └──────────────┘
              │
         ┌────▼─────────┐
         │ Scale DOWN   │
         │ Remove 1 Pod │
         │ Min 2        │
         └──────────────┘

Current Config: 2-5 replicas (auto-scales based on CPU 70-75%)
```

---

## 📊 Data Flow Diagram

```
User Interface (React)
    ├─ TaskForm Component
    │   ├─ Input validation
    │   └─ fetch POST /tasks
    │
    ├─ TaskList Component
    │   ├─ fetch GET /tasks
    │   └─ Display tasks
    │
    └─ TaskItem Component
        ├─ Display task
        └─ fetch DELETE /tasks/:id
           │
           ▼
Backend API (Express)
    ├─ Routes (tasks.js)
    │   ├─ GET /tasks → Find all
    │   ├─ POST /tasks → Create
    │   └─ DELETE /tasks/:id → Remove
    │
    ├─ Middleware
    │   ├─ CORS enabled
    │   ├─ JSON parsing
    │   └─ Error handling
    │
    └─ Database Connection
           │
           ▼
MongoDB
    ├─ Collections
    │   └─ tasks
    │       ├─ _id (ObjectId)
    │       ├─ title (String)
    │       ├─ completed (Boolean)
    │       ├─ createdAt (Date)
    │       └─ updatedAt (Date)
    │
    └─ Persistent Storage
        ├─ Docker: Local volume
        └─ K8s: PersistentVolumeClaim (5GB)
```

---

## 🌐 Network Architecture (Kubernetes)

```
INTERNET
   │
   ▼
┌──────────────────────────────────────┐
│ AWS Load Balancer                    │
│ (External IP assigned)               │
└──────────────────┬───────────────────┘
                   │
┌──────────────────▼───────────────────┐
│ Kubernetes Service: frontend-service │
│ Type: LoadBalancer                   │
│ Port: 80 → 80 (container)            │
└──────────────────┬───────────────────┘
                   │
         ┌─────────┼────────┬──────────┐
         │         │        │          │
    ┌────▼──┐ ┌────▼──┐ ┌───▼───┐ ...
    │Pod 1  │ │Pod 2  │ │Pod N  │
    │:80    │ │:80    │ │:80    │
    └────┬──┘ └────┬──┘ └───┬───┘
         │         │        │
         └─────────┼────────┘
                   │
         ┌─────────▼─────────┐
         │ Kubernetes Service│
         │ backend-service   │
         │ Type: ClusterIP   │
         │ Port: 5000        │
         └─────────┬─────────┘
                   │
         ┌─────────┼────────┬──────────┐
         │         │        │          │
    ┌────▼──┐ ┌────▼──┐ ┌───▼───┐ ...
    │Pod 1  │ │Pod 2  │ │Pod N  │
    │:5000  │ │:5000  │ │:5000  │
    └────┬──┘ └────┬──┘ └───┬───┘
         │         │        │
         └─────────┼────────┘
                   │
         ┌─────────▼─────────┐
         │ Kubernetes Service│
         │ mongodb-service   │
         │ Type: ClusterIP   │
         │ Port: 27017       │
         └─────────┬─────────┘
                   │
              ┌────▼────┐
              │MongoDB  │
              │:27017   │
              └─────────┘
```

---

## 📈 Scaling Scenario

```
NORMAL TRAFFIC (CPU 40-50%)
────────────────────────────────────────
Replicas:
  ├─ Frontend: 2 pods
  ├─ Backend: 2 pods
  └─ MongoDB: 1 pod (stateful)

PEAK TRAFFIC (CPU 80%+)
────────────────────────────────────────
HPA Triggers:
  ├─ CPU > 75%
  ├─ Duration > 30 seconds
  └─ Action: Scale UP

After HPA Action:
  ├─ Frontend: 2 → 3 → 4 → 5 pods
  ├─ Backend: 2 → 3 → 4 → 5 pods
  └─ MongoDB: 1 pod (no auto-scale)

Result:
  ├─ 10 total pods (vs 5 originally)
  ├─ 2x processing capacity
  └─ Handled peak traffic

LOW TRAFFIC (CPU 20-30%)
────────────────────────────────────────
HPA Triggers:
  ├─ CPU < 50% for 5 minutes
  └─ Action: Scale DOWN

After HPA Action (if safe):
  ├─ Frontend: 5 → 4 → 3 → 2 pods
  ├─ Backend: 5 → 4 → 3 → 2 pods
  └─ Always maintain minimum 2 replicas

Result:
  ├─ Back to normal
  ├─ Cost optimization
  └─ Resource efficiency
```

---

## 🔐 Security Architecture

```
                          Public Internet
                                │
                    ┌───────────▼──────────────┐
                    │ AWS Security Group       │
                    │ - Allow :80, :443        │
                    │ - Allow :443 TLS         │
                    └───────────┬──────────────┘
                                │
                    ┌───────────▼──────────────┐
                    │ Load Balancer            │
                    │ (External IP only)       │
                    └───────────┬──────────────┘
                                │
          Private Kubernetes Cluster
                                │
                    ┌───────────▼──────────────┐
                    │ Frontend Service         │
                    │ (ClusterIP only)         │
                    └───────────┬──────────────┘
                                │
                    ┌───────────▼──────────────┐
                    │ Backend Service          │
                    │ (ClusterIP only)         │
                    │ No external access       │
                    └───────────┬──────────────┘
                                │
                    ┌───────────▼──────────────┐
                    │ MongoDB Service          │
                    │ (ClusterIP only)         │
                    │ Internal only            │
                    └──────────────────────────┘

Security Features:
  ✓ Services isolated to ClusterIP
  ✓ Network policies can be added
  ✓ Pod security policies enforced
  ✓ Resource limits prevent DoS
  ✓ Health checks detect anomalies
```

---

## 📊 Resource Allocation

```
FRONTEND PODS (per pod)
  ├─ Requests:
  │   ├─ CPU: 50m (0.05 cores)
  │   └─ Memory: 64Mi
  └─ Limits:
      ├─ CPU: 200m (0.2 cores)
      └─ Memory: 128Mi

BACKEND PODS (per pod)
  ├─ Requests:
  │   ├─ CPU: 100m (0.1 cores)
  │ └─ Memory: 128Mi
  └─ Limits:
      ├─ CPU: 500m (0.5 cores)
      └─ Memory: 256Mi

MONGODB POD
  ├─ Requests:
  │   ├─ CPU: 100m (0.1 cores)
  │   └─ Memory: 256Mi
  └─ Limits:
      ├─ CPU: 500m (0.5 cores)
      └─ Memory: 512Mi

TOTAL (at minimum: 2 frontend + 2 backend + 1 mongo)
  ├─ Requested: ~600m CPU, ~704Mi RAM
  ├─ Limit: ~2200m CPU, ~1408Mi RAM
  └─ All fits in < 1GB node or 2GB minimum
```

---

**Created:** April 14, 2026
**Version:** 1.0.0
**Status:** Production Ready
