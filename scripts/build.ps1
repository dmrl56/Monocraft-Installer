# Monocraft Font Tool - Main Build Script
#
# This script builds the application using jpackage to create a standalone
# native package with bundled JRE. This is the recommended build method.
#
# For the alternative Launch4j build (requires Java on target machine), 
# use: .\scripts\build-launch4j.ps1
#
# Requirements:
# - JDK 17 or higher (includes javac, jar, jlink, and jpackage)
#
# Run with: .\scripts\build.ps1

param(
    [ValidateSet('app-image', 'exe', 'msi')]
    [string]$PackageType = 'exe'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$srcDir = Join-Path $projectRoot 'src'
$javaSourceDir = Join-Path $srcDir 'com\example'
$buildDir = Join-Path $projectRoot 'build'
$classDir = Join-Path $buildDir 'classes'
$jarName = 'MonocraftFontInstaller.jar'
$jarPath = Join-Path $buildDir $jarName
$manifest = Join-Path $buildDir 'manifest.txt'

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " Monocraft Font Tool - Build Script" -ForegroundColor Cyan
Write-Host " Building with jpackage (standalone distribution)" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Ensure build directory exists
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    Write-Host 'Created build directory' -ForegroundColor Gray
}
if (!(Test-Path $classDir)) {
    New-Item -ItemType Directory -Path $classDir -Force | Out-Null
}

# 1. Compile Java code
Write-Host '==> Compiling Java source...'
$javaFiles = Get-ChildItem -Path $javaSourceDir -Filter "*.java" | ForEach-Object { $_.FullName }
javac -d $classDir $javaFiles
if ($LASTEXITCODE -ne 0) { 
    Write-Error 'Java compilation failed.' 
    exit 1 
}
Write-Host '[OK] Java compilation successful' -ForegroundColor Green

# 2. Create JAR file with manifest
Write-Host '==> Creating JAR file...'
if (!(Test-Path $manifest)) {
    Set-Content -Path $manifest -Value "Main-Class: com.example.MonocraftFontInstaller`r`n"
}

# Include fonts in the jar if available
$fontsPath = Join-Path $projectRoot 'resources\fonts\Monocraft-font'
if (Test-Path $fontsPath) {
    Write-Host 'Including Monocraft-font folder in JAR' -ForegroundColor Gray
    jar cfm $jarPath $manifest -C $classDir com -C (Join-Path $projectRoot 'resources\fonts') Monocraft-font
} else {
    jar cfm $jarPath $manifest -C $classDir com
}

if ($LASTEXITCODE -ne 0) { 
    Write-Error 'JAR creation failed.' 
    exit 1 
}
Write-Host '[OK] JAR created: $jarName' -ForegroundColor Green

# 3. Call package.ps1 to create native package with jpackage
Write-Host "`n==> Creating native package with jpackage..."
$packageScript = Join-Path $scriptDir 'package.ps1'
& $packageScript -Type $PackageType

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Package creation failed.'
    exit 1
}

Write-Host "`n================================================" -ForegroundColor Green
Write-Host " Build Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "`nOutput: build\package\MonocraftFontTool\" -ForegroundColor Cyan
Write-Host ""

