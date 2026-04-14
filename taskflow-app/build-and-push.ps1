# TaskFlow Docker Build & Push Script (Windows PowerShell)
# This script builds Docker images and pushes them to Amazon ECR

param(
    [string]$AwsRegion = "us-east-1",
    [string]$AwsAccountId = "",
    [string]$ImageTag = "latest"
)

# Validate AWS Account ID
if ([string]::IsNullOrEmpty($AwsAccountId)) {
    Write-Host "Error: AWS_ACCOUNT_ID parameter is required" -ForegroundColor Red
    Write-Host "Usage: .\build-and-push.ps1 -AwsAccountId 123456789 -AwsRegion us-east-1 -ImageTag latest" -ForegroundColor Yellow
    exit 1
}

$EcrRegistry = "$AwsAccountId.dkr.ecr.$AwsRegion.amazonaws.com"

Write-Host "=== TaskFlow Docker Build & Push ===" -ForegroundColor Yellow
Write-Host "AWS Region: $AwsRegion"
Write-Host "AWS Account ID: $AwsAccountId"
Write-Host "ECR Registry: $EcrRegistry"
Write-Host ""

# Login to ECR
Write-Host "Logging in to ECR..." -ForegroundColor Yellow
$LoginPassword = aws ecr get-login-password --region $AwsRegion
$LoginPassword | docker login --username AWS --password-stdin $EcrRegistry
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ ECR login successful" -ForegroundColor Green
} else {
    Write-Host "✗ ECR login failed" -ForegroundColor Red
    exit 1
}

# Build and push frontend
Write-Host ""
Write-Host "Building frontend image..." -ForegroundColor Yellow
Set-Location frontend
docker build -t taskflow-frontend:$ImageTag .
if ($LASTEXITCODE -ne 0) { exit 1 }
docker tag taskflow-frontend:$ImageTag "$EcrRegistry/taskflow-frontend:$ImageTag"
Write-Host "✓ Frontend image built" -ForegroundColor Green

Write-Host "Pushing frontend to ECR..." -ForegroundColor Yellow
docker push "$EcrRegistry/taskflow-frontend:$ImageTag"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "✓ Frontend pushed to ECR" -ForegroundColor Green
Set-Location ..

# Build and push backend
Write-Host ""
Write-Host "Building backend image..." -ForegroundColor Yellow
Set-Location backend
docker build -t taskflow-backend:$ImageTag .
if ($LASTEXITCODE -ne 0) { exit 1 }
docker tag taskflow-backend:$ImageTag "$EcrRegistry/taskflow-backend:$ImageTag"
Write-Host "✓ Backend image built" -ForegroundColor Green

Write-Host "Pushing backend to ECR..." -ForegroundColor Yellow
docker push "$EcrRegistry/taskflow-backend:$ImageTag"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "✓ Backend pushed to ECR" -ForegroundColor Green
Set-Location ..

Write-Host ""
Write-Host "=== Build & Push Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Frontend: $EcrRegistry/taskflow-frontend:$ImageTag"
Write-Host "Backend: $EcrRegistry/taskflow-backend:$ImageTag"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update kubernetes/backend-deployment.yaml with new image URI"
Write-Host "2. Update kubernetes/frontend-deployment.yaml with new image URI"
Write-Host "3. Run: kubectl apply -f kubernetes/"
