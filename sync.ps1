# sync.ps1 - Sync GitHub <-> TFS remotes

Write-Host "🔄 Starting sync process..." -ForegroundColor Cyan

# Step 1: Pull latest changes from GitHub
Write-Host "⬇️  Pulling from GitHub..." -ForegroundColor Yellow
git pull github --all

# Step 2: Push everything to TFS
Write-Host "⬆️  Pushing to TFS..." -ForegroundColor Yellow
git push origin --all
git push origin --tags

# Step 3: Push everything to GitHub (to sync office commits as well)
Write-Host "⬆️  Pushing to GitHub..." -ForegroundColor Yellow
git push github --all
git push github --tags

Write-Host "✅ Sync completed successfully!" -ForegroundColor Green
