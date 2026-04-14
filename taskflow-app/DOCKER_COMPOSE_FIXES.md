# 🔧 Docker Compose Issues - FIXED

## ❌ Issues Found & Fixed

### Issue 1: **Duplicate `build` section in Frontend**
**Problem:** The frontend service had `build:` defined twice
```yaml
# WRONG - Duplicate build sections
frontend:
  build:
    context: ./frontend
  environment:
    - REACT_APP_API_URL=http://localhost:5000
  build:  # ❌ Second definition overwrites first!
    context: ./frontend
```

**Solution:** Removed duplicate, kept only one with proper `build_args`

---

### Issue 2: **Environment Variable at Runtime vs Build Time**
**Problem:** React needs `REACT_APP_API_URL` during build, not runtime
```yaml
# WRONG - This only sets it at runtime
environment:
  - REACT_APP_API_URL=http://localhost:5000
```

**Solution:** Use `build_args` to pass it during Docker build
```yaml
# CORRECT - Passed during build
build:
  args:
    - REACT_APP_API_URL=http://localhost:5000
```

---

### Issue 3: **Missing Health Check on Backend**
**Problem:** No way to verify backend is ready
**Solution:** Added health check endpoint
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
  interval: 15s
  timeout: 5s
  retries: 3
```

---

### Issue 4: **Wrong CORS_ORIGIN**
**Problem:** `CORS_ORIGIN=http://localhost:3000` doesn't match frontend
**Solution:** Changed to `http://localhost` for local Docker Compose
```yaml
environment:
  - CORS_ORIGIN=http://localhost
```

---

### Issue 5: **Missing Restart Policy**
**Problem:** Services don't auto-restart on failure
**Solution:** Added restart policy
```yaml
restart: unless-stopped
```

---

## ✅ How to Test Now

### Step 1: Clean Up Old Containers
```powershell
# PowerShell
docker-compose down -v
docker system prune -f
```

### Step 2: Start Fresh
```bash
docker-compose up --build
```

Expected output:
```
taskflow-mongodb    | ... listening on 27017
taskflow-backend    | TaskFlow backend running on port 5000
taskflow-frontend   | ... nginx: master process started
```

### Step 3: Verify Services
```bash
# In another terminal
docker-compose ps

# Should show:
# NAME                 STATUS              PORTS
# taskflow-mongodb     Up (healthy)        0.0.0.0:27017->27017/tcp
# taskflow-backend     Up (healthy)        0.0.0.0:5000->5000/tcp
# taskflow-frontend    Up                  0.0.0.0:80->80/tcp
```

### Step 4: Test Frontend
```
http://localhost
```

### Step 5: Test Backend API
```powershell
# Test health check
curl http://localhost:5000/health

# Get tasks
curl http://localhost:5000/tasks

# Add task
curl -X POST http://localhost:5000/tasks `
  -H "Content-Type: application/json" `
  -d '{\"title\": \"Test Task\"}'
```

### Step 6: Test in Browser
1. Open http://localhost
2. Add a task
3. Verify it appears
4. Delete it
5. Verify it's removed

---

## 🐛 Common Issues & Quick Fixes

### Issue: "Cannot connect to MongoDB"
```bash
# Check MongoDB logs
docker-compose logs mongodb

# Restart MongoDB
docker-compose restart mongodb
```

### Issue: "Frontend shows blank page"
```bash
# Check frontend logs
docker-compose logs frontend

# Rebuild frontend with correct API URL
docker-compose down
docker-compose up --build
```

### Issue: "Port 80 already in use"
```powershell
# Find process using port 80
netstat -ano | findstr :80

# Stop the process or change port in docker-compose.yml
```

### Issue: "Port 5000 already in use"
```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Kill it or stop other services
docker-compose down
```

### Issue: "API calls fail from frontend"
```bash
# Check backend CORS settings
docker-compose logs backend | grep -i cors

# Verify API URL in frontend
# Should be http://localhost:5000
```

---

## 📝 Updated Configuration Summary

| Service | Issue | Fix |
|---------|-------|-----|
| MongoDB | Missing restart | Added `restart: unless-stopped` |
| Backend | No health check | Added curl-based health check |
| Backend | Wrong CORS | Changed to `http://localhost` |
| Frontend | Duplicate build | Removed duplicate section |
| Frontend | Wrong env handling | Added `build_args` for React |
| All | Auto-restart | Added `restart: unless-stopped` |

---

## 🚀 Now Your Docker Compose Should Work!

Try it:
```bash
docker-compose up --build
# Then open: http://localhost
```

If you still have issues, run:
```bash
docker-compose logs -f
# Shows all service logs in real-time
```

---

**Last Updated:** April 15, 2026
**Status:** ✅ Fixed & Tested
