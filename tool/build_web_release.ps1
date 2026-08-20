[CmdletBinding()]
param(
  [ValidatePattern('^/.*/$|^/$')]
  [string]$BaseHref = '/',

  [string]$ArtifactName = 'anet-merchants-web'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$distDirectory = Join-Path $projectRoot 'dist'
$webBuildDirectory = Join-Path $projectRoot 'build\web'
$archivePath = Join-Path $distDirectory "$ArtifactName.zip"
$checksumPath = "$archivePath.sha256"

Push-Location $projectRoot
try {
  Write-Host 'Restoring Flutter packages...'
  flutter pub get

  Write-Host 'Checking Dart formatting...'
  dart format --output=none --set-exit-if-changed lib test

  Write-Host 'Running static analysis...'
  flutter analyze

  Write-Host 'Running automated tests...'
  flutter test

  Write-Host "Building release web bundle with base href '$BaseHref'..."
  flutter build web --release --base-href $BaseHref

  if (-not (Test-Path -LiteralPath $webBuildDirectory)) {
    throw "Flutter did not create the expected directory: $webBuildDirectory"
  }

  New-Item -ItemType Directory -Path $distDirectory -Force | Out-Null
  Remove-Item -LiteralPath $archivePath -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $checksumPath -Force -ErrorAction SilentlyContinue
  Compress-Archive -Path (Join-Path $webBuildDirectory '*') `
    -DestinationPath $archivePath -CompressionLevel Optimal

  $checksum = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
  Set-Content -LiteralPath $checksumPath -Value "$checksum  $ArtifactName.zip"

  Write-Host ''
  Write-Host 'Release artifact created:'
  Write-Host "  $archivePath"
  Write-Host "  $checksumPath"
}
finally {
  Pop-Location
}
