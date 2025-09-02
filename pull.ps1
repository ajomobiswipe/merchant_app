Write-Host "🔄 Starting sync process..." -ForegroundColor Cyan

# Step 1: Fetch and pull latest changes from GitHub
Write-Host "⬇️  Fetching from GitHub..." -ForegroundColor Yellow
git fetch github
git pull github master --rebase



# .\sync.ps1