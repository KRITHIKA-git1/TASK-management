# TaskFlow - Environment Variables Reference

## Backend Environment Variables

### Backend `.env` File

```ini
# Server Configuration
PORT=5000                                    # Server port (default: 5000)
NODE_ENV=development                        # Environment: development, production, test

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/taskflow    # MongoDB connection string
# For Docker/K8s: mongodb://mongodb-service:27017/taskflow
# For Local: mongodb://localhost:27017/taskflow
# With Auth: mongodb://user:password@host:27017/taskflow

# CORS Configuration
CORS_ORIGIN=http://localhost:3000           # Frontend URL for CORS
# For Docker Compose: http://localhost
# For K8s: http://taskflow-frontend
# For Production: https://yourdomain.com
```

### Backend Configuration Details

| Variable | Default | Purpose | Example |
|----------|---------|---------|---------|
| PORT | 5000 | Express server port | 3000, 8080, 5000 |
| NODE_ENV | development | Node environment | development, production |
| MONGODB_URI | localhost:27017 | MongoDB connection | mongodb://user:pass@host/db |
| CORS_ORIGIN | localhost:3000 | Allowed frontend origin | http://example.com |

### Backend Environment by Deployment

**Local Development:**
```ini
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/taskflow
CORS_ORIGIN=http://localhost:3000
```

**Docker Compose:**
```ini
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://mongodb:27017/taskflow
CORS_ORIGIN=http://localhost
```

**Kubernetes (from ConfigMap):**
```ini
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb://mongodb-service:27017/taskflow
CORS_ORIGIN=http://taskflow-frontend
```

---

## Frontend Environment Variables

### Frontend `.env` File

```ini
# API Configuration
REACT_APP_API_URL=http://localhost:5000      # Backend API URL
# For Docker Compose: http://localhost:5000
# For K8s: http://backend-service:5000
# For Production: https://api.yourdomain.com
```

### Frontend Configuration Details

| Variable | Default | Purpose | Example |
|----------|---------|---------|---------|
| REACT_APP_API_URL | http://localhost:5000 | Backend API endpoint | http://api.example.com |

### Frontend Environment by Deployment

**Local Development:**
```ini
REACT_APP_API_URL=http://localhost:5000
```

**Docker Compose:**
```ini
REACT_APP_API_URL=http://localhost:5000
# or for backend-frontend communication
REACT_APP_API_URL=http://backend:5000
```

**Kubernetes (from ConfigMap):**
```ini
REACT_APP_API_URL=http://backend-service:5000
```

**Production (AWS):**
```ini
REACT_APP_API_URL=https://api.taskflow.example.com
```

---

## Kubernetes ConfigMap Configuration

### namespace-configmap.yaml

The following ConfigMaps are created automatically:

**backend-config:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: taskflow
data:
  NODE_ENV: "production"
  CORS_ORIGIN: "http://taskflow-frontend"
```

**frontend-config:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: taskflow
data:
  REACT_APP_API_URL: "http://backend-service:5000"
```

### Updating ConfigMaps

To update ConfigMap values:

```bash
# Update backend config
kubectl create configmap backend-config \
  --from-literal=NODE_ENV=production \
  --from-literal=CORS_ORIGIN=http://taskflow-frontend \
  -n taskflow --dry-run=client -o yaml | kubectl apply -f -

# Update frontend config
kubectl create configmap frontend-config \
  --from-literal=REACT_APP_API_URL=http://backend-service:5000 \
  -n taskflow --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to apply changes
kubectl rollout restart deployment/backend -n taskflow
kubectl rollout restart deployment/frontend -n taskflow
```

---

## Docker Compose Environment

### docker-compose.yml Services

**MongoDB Service:**
```yaml
environment:
  MONGO_INITDB_DATABASE: taskflow
```

**Backend Service:**
```yaml
environment:
  - NODE_ENV=development
  - MONGODB_URI=mongodb://mongodb:27017/taskflow
  - CORS_ORIGIN=http://localhost
```

**Frontend Service:**
```yaml
environment:
  - REACT_APP_API_URL=http://localhost:5000
```

---

## AWS ECR Configuration

### AWS Credentials (for pushing images)

**Linux/Mac:**
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

# ~/.aws/config
[default]
region = us-east-1
output = json
```

**Windows PowerShell:**
```powershell
# In terminal or profile
$env:AWS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY = "YOUR_SECRET_KEY"
$env:AWS_DEFAULT_REGION = "us-east-1"

# Or use AWS CLI
aws configure
```

### ECR Push Configuration

```bash
# Required variables for build-and-push.sh
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=123456789012
export IMAGE_TAG=latest
```

---

## Environment Variable Priority

Variables are loaded in this order (later overrides earlier):

1. **Default values** (in code)
2. **.env.example** files (templates)
3. **.env** files (local overrides)
4. **System environment variables** (highest priority)
5. **Kubernetes ConfigMaps** (for K8s deployments)

---

## Quick Reference: Common Scenarios

### Scenario 1: Local Development
```bash
# Backend
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/taskflow
CORS_ORIGIN=http://localhost:3000

# Frontend
REACT_APP_API_URL=http://localhost:5000
```

### Scenario 2: Docker Compose Testing
```bash
# Backend (via compose)
NODE_ENV=development
MONGODB_URI=mongodb://mongodb:27017/taskflow
CORS_ORIGIN=http://localhost

# Frontend (via compose)
REACT_APP_API_URL=http://localhost:5000
```

### Scenario 3: Kubernetes on EKS
```bash
# From ConfigMaps
NODE_ENV=production
CORS_ORIGIN=http://taskflow-frontend
REACT_APP_API_URL=http://backend-service:5000
MONGODB_URI=mongodb://mongodb-service:27017/taskflow
```

### Scenario 4: Production on AWS
```bash
# Backend
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/taskflow
CORS_ORIGIN=https://app.example.com

# Frontend
REACT_APP_API_URL=https://api.example.com
```

---

## Troubleshooting

### Issue: "Cannot connect to backend"
**Check:** 
- Frontend `REACT_APP_API_URL` is correct
- Backend `CORS_ORIGIN` includes frontend URL
- Backend is running and accessible

```bash
# Test backend connectivity
curl http://localhost:5000/health
```

### Issue: "MongoDB connection failed"
**Check:**
- Backend `MONGODB_URI` is correct
- MongoDB service is running
- Connection string has correct format

```bash
# Test MongoDB connection
mongosh $MONGODB_URI
```

### Issue: "CORS error in browser console"
**Check:**
- Backend `CORS_ORIGIN` matches frontend URL exactly
- Backend CORS middleware is configured
- Request includes credentials if needed

**Fix:**
```bash
# Update backend .env
CORS_ORIGIN=http://correct-frontend-url:port

# Or in K8s ConfigMap
kubectl set env configmap/backend-config \
  CORS_ORIGIN=http://new-url -n taskflow
```

---

## Security Best Practices

1. **Never commit `.env` files** to git (.gitignore them)
2. **Use different credentials** for each environment
3. **Rotate secrets regularly** in production
4. **Use secrets management** (AWS Secrets Manager, HashiCorp Vault)
5. **Don't log sensitive data** (passwords, tokens)
6. **Use environment variables** instead of hardcoding

---

## References

- [Node.js Environment Variables](https://nodejs.org/en/knowledge/file-system/security/introduction/)
- [React Environment Variables](https://create-react-app.dev/docs/adding-custom-environment-variables/)
- [MongoDB Connection String](https://docs.mongodb.com/manual/reference/connection-string/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)

---

**Last Updated:** April 2024
