# TaskFlow Local Setup Script - Automated Setup (Windows PowerShell)

param(
    [switch]$SkipInstall = $false
)

# Colors
$ColorGreen = "Green"
$ColorYellow = "Yellow"
$ColorBlue = "Cyan"
$ColorRed = "Red"

Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor $ColorBlue
Write-Host "║  TaskFlow Local Setup" -ForegroundColor $ColorBlue
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor $ColorBlue
Write-Host ""

# Step 1: Check Node.js
Write-Host "Step 1: Checking Node.js installation..." -ForegroundColor $ColorYellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Node.js not found. Please install Node.js 18+" -ForegroundColor $ColorRed
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor $ColorYellow
    exit 1
}
$nodeVersion = node -v
Write-Host "✓ Node.js installed: $nodeVersion" -ForegroundColor $ColorGreen
Write-Host ""

# Step 2: Setup Backend
Write-Host "Step 2: Setting up backend..." -ForegroundColor $ColorYellow
Set-Location backend
Write-Host "Installing backend dependencies..." -ForegroundColor $ColorYellow
npm install
Write-Host "Creating .env file..." -ForegroundColor $ColorYellow
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "✓ Created .env file (check and update if needed)" -ForegroundColor $ColorGreen
} else {
    Write-Host "✓ .env file already exists" -ForegroundColor $ColorGreen
}
Set-Location ..
Write-Host ""

# Step 3: Setup Frontend
Write-Host "Step 3: Setting up frontend..." -ForegroundColor $ColorYellow
Set-Location frontend
Write-Host "Installing frontend dependencies..." -ForegroundColor $ColorYellow
npm install
Write-Host "Creating .env file..." -ForegroundColor $ColorYellow
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "✓ Created .env file" -ForegroundColor $ColorGreen
} else {
    Write-Host "✓ .env file already exists" -ForegroundColor $ColorGreen
}
Set-Location ..
Write-Host ""

# Step 4: Check MongoDB
Write-Host "Step 4: Checking MongoDB..." -ForegroundColor $ColorYellow
if (Get-Command mongosh -ErrorAction SilentlyContinue) {
    Write-Host "✓ MongoDB client installed" -ForegroundColor $ColorGreen
} else {
    Write-Host "⚠ MongoDB client not found (optional)" -ForegroundColor $ColorYellow
    Write-Host "Install from: https://www.mongodb.com/try/download/shell" -ForegroundColor $ColorYellow
    Write-Host "Or use Docker: docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7" -ForegroundColor $ColorYellow
}
Write-Host ""

# Complete
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor $ColorBlue
Write-Host "✓ Setup Complete!" -ForegroundColor $ColorGreen
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "To start the application:" -ForegroundColor $ColorYellow
Write-Host ""
Write-Host "Terminal 1 - Start MongoDB (if not running):" -ForegroundColor ""
Write-Host "  docker run -d -p 27017:27017 --name taskflow-mongodb mongo:7" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Terminal 2 - Start Backend:" -ForegroundColor ""
Write-Host "  cd backend" -ForegroundColor $ColorBlue
Write-Host "  npm start" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Terminal 3 - Start Frontend:" -ForegroundColor ""
Write-Host "  cd frontend" -ForegroundColor $ColorBlue
Write-Host "  npm start" -ForegroundColor $ColorBlue
Write-Host ""
Write-Host "Then open: http://localhost:3000" -ForegroundColor $ColorGreen
Write-Host ""
