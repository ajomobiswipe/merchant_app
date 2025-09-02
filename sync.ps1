

# Step 2: Push everything to TFS
Write-Host "⬆️  Pushing to TFS..." -ForegroundColor Yellow
git push origin --all
git push origin --tags

# Step 3: Push everything to GitHub
Write-Host "⬆️  Pushing to GitHub..." -ForegroundColor Yellow
git push github --all
git push github --tags

Write-Host "✅ Sync completed successfully!" -ForegroundColor Green


# .\sync.ps1