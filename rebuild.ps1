# Rebuild script - cleans and builds the project
# Run with .\rebuild.ps1

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host '=== Starting Rebuild ===' -ForegroundColor Cyan
Write-Host ''

# 1. Run clean script
Write-Host 'Step 1: Cleaning...' -ForegroundColor Yellow
& (Join-Path $projectRoot 'clean.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Clean failed!'
    exit 1
}

Write-Host ''
Write-Host 'Waiting for file system...' -ForegroundColor Gray
Start-Sleep -Milliseconds 500

# 2. Run build script
Write-Host ''
Write-Host 'Step 2: Building...' -ForegroundColor Yellow
& (Join-Path $projectRoot 'build-monocraft-font-installer.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Build failed!'
    exit 1
}

Write-Host ''
Write-Host '=== Rebuild Complete ===' -ForegroundColor Green
