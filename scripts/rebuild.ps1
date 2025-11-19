# Rebuild script - cleans and builds the project
# Run with .\scripts\rebuild.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

Write-Host '=== Starting Rebuild ===' -ForegroundColor Cyan
Write-Host ''

# 1. Run clean script
Write-Host 'Step 1: Cleaning...' -ForegroundColor Yellow
& (Join-Path $scriptDir 'clean.ps1')
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
& (Join-Path $scriptDir 'build.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Build failed!'
    exit 1
}

Write-Host ''
Write-Host '=== Rebuild Complete ===' -ForegroundColor Green
