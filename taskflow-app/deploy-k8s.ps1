# TaskFlow Kubernetes Deployment Script (Windows PowerShell)
# This script deploys TaskFlow to Kubernetes cluster

param(
    [string]$AwsRegion = "us-east-1",
    [string]$AwsAccountId = ""
)

# Colors for output
$ColorRed = "Red"
$ColorGreen = "Green"
$ColorYellow = "Yellow"
$ColorBlue = "Cyan"

Write-Host "================================================" -ForegroundColor $ColorYellow
Write-Host "  TaskFlow Kubernetes Deployment" -ForegroundColor $ColorYellow
Write-Host "================================================" -ForegroundColor $ColorYellow
Write-Host ""

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: kubectl is not installed" -ForegroundColor $ColorRed
    Write-Host "Please install kubectl: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor $ColorYellow
    exit 1
}

# Check cluster connection
Write-Host "Checking Kubernetes cluster..." -ForegroundColor $ColorBlue
$clusterInfo = kubectl cluster-info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Not connected to Kubernetes cluster" -ForegroundColor $ColorRed
    Write-Host "Please configure kubectl or connect to your cluster" -ForegroundColor $ColorYellow
    exit 1
}
Write-Host "✓ Connected to Kubernetes cluster" -ForegroundColor $ColorGreen

Write-Host ""
$context = kubectl config current-context
Write-Host "Current Context: $context" -ForegroundColor $ColorBlue
Write-Host ""

# Step 1: Create namespace and ConfigMaps
Write-Host "Step 1: Creating namespace and ConfigMaps..." -ForegroundColor $ColorYellow
kubectl apply -f kubernetes/namespace-configmap.yaml
Write-Host "✓ Namespace and ConfigMaps created" -ForegroundColor $ColorGreen

# Step 2: Deploy MongoDB
Write-Host ""
Write-Host "Step 2: Deploying MongoDB..." -ForegroundColor $ColorYellow
kubectl apply -f kubernetes/mongodb-deployment.yaml
Write-Host "✓ MongoDB deployment created" -ForegroundColor $ColorGreen

Write-Host "Waiting for MongoDB to be ready..." -ForegroundColor $ColorYellow
$mongoReady = kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=300s 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "MongoDB is taking longer to start. Check status with:" -ForegroundColor $ColorYellow
    Write-Host "kubectl get pods -n taskflow"
    Write-Host "kubectl logs -f -l app=mongodb -n taskflow"
}
Write-Host "✓ MongoDB is ready" -ForegroundColor $ColorGreen

# Step 3: Deploy Backend
Write-Host ""
Write-Host "Step 3: Deploying Backend..." -ForegroundColor $ColorYellow
kubectl apply -f kubernetes/backend-deployment.yaml
Write-Host "✓ Backend deployment created" -ForegroundColor $ColorGreen

Write-Host "Waiting for Backend to be ready..." -ForegroundColor $ColorYellow
$backendReady = kubectl wait --for=condition=ready pod -l app=backend -n taskflow --timeout=300s 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Backend is taking longer to start. Check status with:" -ForegroundColor $ColorYellow
    Write-Host "kubectl get pods -n taskflow"
    Write-Host "kubectl logs -f -l app=backend -n taskflow"
}
Write-Host "✓ Backend is ready" -ForegroundColor $ColorGreen

# Step 4: Deploy Frontend
Write-Host ""
Write-Host "Step 4: Deploying Frontend..." -ForegroundColor $ColorYellow
kubectl apply -f kubernetes/frontend-deployment.yaml
Write-Host "✓ Frontend deployment created" -ForegroundColor $ColorGreen

Write-Host "Waiting for Frontend to be ready..." -ForegroundColor $ColorYellow
$frontendReady = kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=300s 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend is taking longer to start. Check status with:" -ForegroundColor $ColorYellow
    Write-Host "kubectl get pods -n taskflow"
    Write-Host "kubectl logs -f -l app=frontend -n taskflow"
}
Write-Host "✓ Frontend is ready" -ForegroundColor $ColorGreen

# Step 5: Deploy HPA
Write-Host ""
Write-Host "Step 5: Deploying Horizontal Pod Autoscaler..." -ForegroundColor $ColorYellow
kubectl apply -f kubernetes/hpa.yaml
Write-Host "✓ HPA deployed" -ForegroundColor $ColorGreen

# Deployment complete
Write-Host ""
Write-Host "================================================" -ForegroundColor $ColorGreen
Write-Host "  ✓ Deployment Complete!" -ForegroundColor $ColorGreen
Write-Host "================================================" -ForegroundColor $ColorGreen
Write-Host ""

# Get service information
Write-Host "Deployment Status:" -ForegroundColor $ColorBlue
Write-Host ""
kubectl get all -n taskflow
Write-Host ""

# Get LoadBalancer IP
Write-Host "Getting LoadBalancer IP..." -ForegroundColor $ColorBlue
$frontendService = kubectl get service frontend-service -n taskflow -o json | ConvertFrom-Json
$frontendIp = $frontendService.status.loadBalancer.ingress[0].ip

if ($null -eq $frontendIp -or $frontendIp -eq "") {
    Write-Host "⏳ Frontend LoadBalancer IP is pending (can take a few minutes on cloud providers)" -ForegroundColor $ColorYellow
    Write-Host ""
    Write-Host "To get the external IP, run:" -ForegroundColor ""
    Write-Host ""
    Write-Host "kubectl get service frontend-service -n taskflow" -ForegroundColor $ColorBlue
    Write-Host ""
    Write-Host "Or watch for updates:" -ForegroundColor ""
    Write-Host ""
    Write-Host "kubectl get service -w -n taskflow" -ForegroundColor $ColorBlue
} else {
    Write-Host "✓ Frontend accessible at: http://$frontendIp" -ForegroundColor $ColorGreen
}

Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "View pods:"
Write-Host "  kubectl get pods -n taskflow" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "View logs:"
Write-Host "  kubectl logs -f <pod-name> -n taskflow" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Port forward to frontend:"
Write-Host "  kubectl port-forward svc/frontend-service 8080:80 -n taskflow" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Port forward to backend:"
Write-Host "  kubectl port-forward svc/backend-service 5000:5000 -n taskflow" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Delete deployment:"
Write-Host "  kubectl delete namespace taskflow" -ForegroundColor $ColorBlue
