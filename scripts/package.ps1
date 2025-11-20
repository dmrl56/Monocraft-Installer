# Monocraft Font Tool - Native Package Builder using jpackage
#
# Creates a true single-distribution native package with bundled JRE.
# The result does NOT require Java to be installed on the target machine.
#
# Requirements:
# - JDK 17 or higher (includes jpackage and jlink)
# - WiX Toolset 3.14+ (for exe/msi installers: scoop install versions/wixtoolset3)
# - Run .\scripts\build.ps1 first to ensure JAR is built
#
# Usage:
#   .\scripts\package.ps1                  # Creates exe installer (default)
#   .\scripts\package.ps1 -Type app-image  # Creates portable folder
#   .\scripts\package.ps1 -Type msi        # Creates MSI installer

param(
    [ValidateSet('app-image', 'exe', 'msi')]
    [string]$Type = 'exe',
    
    [bool]$UseCustomRuntime = $true,
    
    [string]$JdkPath = $env:JAVA_HOME
)

$ErrorActionPreference = 'Stop'

# Helper Functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Find-JavaTool {
    param([string]$ToolName)
    
    if ($JdkPath -and (Test-Path $JdkPath)) {
        $tool = Join-Path $JdkPath "bin\$ToolName.exe"
        if (Test-Path $tool) {
            return $tool
        }
    }
    
    $tool = Get-Command $ToolName -ErrorAction SilentlyContinue
    if ($tool) {
        return $tool.Source
    }
    
    return $null
}

# Setup
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$buildDir = Join-Path $projectRoot 'build'
$jarPath = Join-Path $buildDir 'MonocraftFontInstaller.jar'
$packageDir = Join-Path $buildDir 'package'
$runtimeDir = Join-Path $buildDir 'runtime'

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " Monocraft Font Tool - Native Package Builder" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Validate Requirements
Write-Step "Validating requirements..."

if (-not (Test-Path $jarPath)) {
    Write-Error "JAR not found at $jarPath. Run .\scripts\build.ps1 first."
}
Write-Success "Found JAR: $jarPath"

$jpackage = Find-JavaTool 'jpackage'
if (-not $jpackage) {
    Write-Error @"
jpackage not found. Requirements:
- JDK 17 or higher must be installed
- Set JAVA_HOME environment variable or use -JdkPath parameter
- Download from: https://adoptium.net/
"@
}
Write-Success "Found jpackage: $jpackage"

$javaVersionOutput = & $jpackage --version 2>&1 | Out-String
if ($javaVersionOutput -match '(\d+)') {
    $javaMajorVersion = [int]$matches[1]
    if ($javaMajorVersion -lt 17) {
        Write-Warning "Java $javaMajorVersion detected. Java 17+ recommended."
    } else {
        Write-Success "Java version: $javaMajorVersion"
    }
}

$jlink = $null
if ($UseCustomRuntime) {
    $jlink = Find-JavaTool 'jlink'
    if ($jlink) {
        Write-Success "Found jlink: $jlink"
    } else {
        Write-Warning "jlink not found. Will use full JRE (larger size)."
        $UseCustomRuntime = $false
    }
}

$iconPath = Join-Path $projectRoot 'app-icon.ico'
if (-not (Test-Path $iconPath)) {
    Write-Warning "No icon found. Run .\scripts\create-icon.ps1 to create one."
    $iconPath = $null
}

# Create Custom Runtime with jlink
if ($UseCustomRuntime -and $jlink) {
    Write-Step "Creating custom runtime image with jlink..."
    
    if (Test-Path $runtimeDir) {
        Remove-Item $runtimeDir -Recurse -Force
    }
    
    $modules = @(
        'java.base',
        'java.desktop',
        'java.logging',
        'java.xml',
        'java.prefs',
        'jdk.crypto.ec'
    )
    
    $moduleList = $modules -join ','
    
    Write-Host "Modules: $moduleList" -ForegroundColor Gray
    
    # Use zip-6 compression for Java 21+, older syntax for earlier versions
    $compressArg = if ($javaMajorVersion -ge 21) { '--compress=zip-6' } else { '--compress=2' }
    
    & $jlink `
        --add-modules $moduleList `
        --strip-debug `
        --no-header-files `
        --no-man-pages `
        $compressArg `
        --output $runtimeDir
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "jlink failed to create runtime image. Try running with -UseCustomRuntime `$false to skip jlink."
    }
    
    Write-Success "Custom runtime created at $runtimeDir"
    
    $runtimeSize = (Get-ChildItem $runtimeDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Runtime size: $([math]::Round($runtimeSize, 2)) MB" -ForegroundColor Gray
}

# Build Package with jpackage
Write-Step "Building $Type package with jpackage..."

if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

$jpackageArgs = @(
    '--input', $buildDir,
    '--name', 'MonocraftFontTool',
    '--main-jar', 'MonocraftFontInstaller.jar',
    '--main-class', 'com.example.MonocraftFontInstaller',
    '--type', $Type,
    '--dest', $packageDir,
    '--app-version', '1.3.3',
    '--description', 'Monocraft Font Configuration Tool for Visual Studio Code',
    '--vendor', 'Monocraft Font Tool',
    '--copyright', 'Copyright 2025'
)

if ($iconPath) {
    $jpackageArgs += '--icon', $iconPath
}

if ($UseCustomRuntime -and (Test-Path $runtimeDir)) {
    $jpackageArgs += '--runtime-image', $runtimeDir
}

if ($Type -eq 'exe' -or $Type -eq 'msi') {
    $jpackageArgs += '--win-menu'
    $jpackageArgs += '--win-menu-group', 'Monocraft Font Tool'
    $jpackageArgs += '--win-shortcut'
    $jpackageArgs += '--win-dir-chooser'
    
    # Add option to run app after installation (Windows only, .exe type)
    if ($Type -eq 'exe') {
        # Create a custom WiX fragment to add launch checkbox
        $wixFragment = Join-Path $buildDir 'launch-after-install.wxs'
        @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Fragment>
    <UI>
      <Publish Dialog="ExitDialog"
               Control="Finish" 
               Event="DoAction" 
               Value="LaunchApplication">WIXUI_EXITDIALOGOPTIONALCHECKBOX = 1 and NOT Installed</Publish>
    </UI>
    <Property Id="WIXUI_EXITDIALOGOPTIONALCHECKBOXTEXT" Value="Launch Monocraft Font Tool" />
    <Property Id="WIXUI_EXITDIALOGOPTIONALCHECKBOX" Value="1" />
    <Property Id="WixShellExecTarget" Value="[#MonocraftFontTool.exe]" />
    <CustomAction Id="LaunchApplication"
                  BinaryKey="WixCA"
                  DllEntry="WixShellExec"
                  Impersonate="yes" />
  </Fragment>
</Wix>
"@ | Out-File -FilePath $wixFragment -Encoding UTF8
        
        $jpackageArgs += '--resource-dir', $buildDir
    }
    
    if ($Type -eq 'msi') {
        $jpackageArgs += '--win-per-user-install'
    }
}

Write-Host "Running jpackage..." -ForegroundColor Gray

& $jpackage @jpackageArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "jpackage failed with exit code $LASTEXITCODE"
}

Write-Success "Package created successfully!"

# Summary
Write-Host "`n================================================" -ForegroundColor Green
Write-Host " Build Summary" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "`nPackage Type: $Type"
Write-Host "Output Location: $packageDir"

$createdPackages = Get-ChildItem $packageDir -Recurse -File | Where-Object { 
    $_.Extension -in @('.exe', '.msi') -or $_.Name -eq 'MonocraftFontTool.exe'
}

if ($createdPackages) {
    Write-Host "`nCreated files:" -ForegroundColor Cyan
    foreach ($pkg in $createdPackages) {
        $sizeMB = [math]::Round($pkg.Length / 1MB, 2)
        Write-Host "  - $($pkg.Name) - Size: $sizeMB MB"
        Write-Host "    Path: $($pkg.FullName)" -ForegroundColor Gray
    }
}

if ($Type -eq 'app-image') {
    $exePath = Join-Path $packageDir 'MonocraftFontTool\MonocraftFontTool.exe'
    if (Test-Path $exePath) {
        Write-Host "`n[SUCCESS] Portable EXE with bundled runtime created!" -ForegroundColor Green
        Write-Host "  You can distribute the entire MonocraftFontTool folder."
        Write-Host "  Users can run the EXE without installing Java."
    }
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
if ($Type -eq 'app-image') {
    Write-Host "  1. Test the EXE in: $packageDir\MonocraftFontTool\"
    Write-Host "  2. ZIP the MonocraftFontTool folder for distribution"
    Write-Host "  3. (Optional) Sign the EXE with .\scripts\sign.ps1"
} else {
    Write-Host "  1. Test the installer in: $packageDir"
    Write-Host "  2. (Optional) Sign the installer with .\scripts\sign.ps1"
    Write-Host "  3. Distribute the installer to users"
}

Write-Host ""
