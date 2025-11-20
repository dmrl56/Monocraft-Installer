# Rebuild script for Launch4j - cleans and builds using Launch4j wrapper
# This is the alternative build method (requires Java on target machine)
# For the default jpackage build, use: .\scripts\rebuild.ps1
# Run with .\scripts\rebuild-launch4j.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

Write-Host '=== Starting Rebuild (Launch4j) ===' -ForegroundColor Cyan
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

# 2. Run Launch4j build script
Write-Host ''
Write-Host 'Step 2: Building with Launch4j...' -ForegroundColor Yellow
& (Join-Path $scriptDir 'build-launch4j.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Build failed!'
    exit 1
}

Write-Host ''
Write-Host '=== Rebuild Complete ===' -ForegroundColor Green
