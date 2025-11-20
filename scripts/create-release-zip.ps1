# Create ZIP archive for GitHub release distribution
# Run with: .\scripts\create-release-zip.ps1

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$packageDir = Join-Path $projectRoot 'build\package\MonocraftFontTool'
$outputDir = Join-Path $projectRoot 'build'
$zipName = 'MonocraftFontTool-v1.3.5-Windows.zip'
$zipPath = Join-Path $outputDir $zipName

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " Creating Release ZIP for GitHub" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Check if package exists
if (-not (Test-Path $packageDir)) {
    Write-Error "Package folder not found at: $packageDir`nRun .\scripts\rebuild.ps1 first."
}

Write-Host "==> Creating ZIP archive..." -ForegroundColor Cyan
Write-Host "Source: $packageDir" -ForegroundColor Gray

# Remove old ZIP if exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "Removed old ZIP" -ForegroundColor Gray
}

# Create ZIP using PowerShell's built-in Compress-Archive
Compress-Archive -Path $packageDir -DestinationPath $zipPath -CompressionLevel Optimal

if (-not (Test-Path $zipPath)) {
    Write-Error "Failed to create ZIP archive"
}

$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "`n[OK] ZIP created successfully!" -ForegroundColor Green
Write-Host "File: $zipName" -ForegroundColor White
Write-Host "Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor White
Write-Host "Path: $zipPath" -ForegroundColor Gray

Write-Host "`n================================================" -ForegroundColor Green
Write-Host " Ready for GitHub Release!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "\nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Go to: https://github.com/dmrl56/vsc-mc-script/releases/new" -ForegroundColor White
  Write-Host "  2. Create a new tag (e.g., v1.3.4)" -ForegroundColor White
Write-Host "  3. Upload: $zipName" -ForegroundColor Yellow
Write-Host "  4. Users download, extract, and run MonocraftFontTool.exe" -ForegroundColor White
Write-Host "`n  Note: Users do NOT need Java installed!" -ForegroundColor Green
Write-Host ""
