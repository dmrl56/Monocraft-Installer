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
#
# TODO: Application should launch after installation when user selects the option

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

# Copy resources folder to build directory for jpackage to include
$resourcesSource = Join-Path $projectRoot 'resources'
$resourcesDest = Join-Path $buildDir 'resources'
if (Test-Path $resourcesSource) {
    Write-Host "Copying resources folder to build directory..." -ForegroundColor Gray
    if (Test-Path $resourcesDest) {
        Remove-Item $resourcesDest -Recurse -Force
    }
    Copy-Item $resourcesSource -Destination $resourcesDest -Recurse -Force
}

$jpackageArgs = @(
    '--input', $buildDir,
    '--name', 'MonocraftFontTool',
    '--main-jar', 'MonocraftFontInstaller.jar',
    '--main-class', 'com.example.MonocraftFontInstaller',
    '--type', $Type,
    '--dest', $packageDir,
    '--app-version', '1.3.4',
    '--description', 'Monocraft Font Configuration Tool for Visual Studio Code',
    '--vendor', 'Monocraft Font Tool',
    '--copyright', 'Copyright 2025',
    '--install-dir', 'MonocraftFontTool'
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
    $jpackageArgs += '--win-shortcut-prompt'
    
    # For .exe installer, add post-install launch via custom file
    if ($Type -eq 'exe') {
        # Create a post-install batch file
        $postInstallDir = Join-Path $buildDir 'post-install'
        if (!(Test-Path $postInstallDir)) {
            New-Item -ItemType Directory -Path $postInstallDir -Force | Out-Null
        }
        
        $launchBat = Join-Path $postInstallDir 'launch.bat'
        @"
@echo off
start "" "MonocraftFontTool.exe"
"@ | Out-File -FilePath $launchBat -Encoding ASCII
        
        Write-Host "Created post-install launch script" -ForegroundColor Gray
    }
    
    if ($Type -eq 'msi') {
        $jpackageArgs += '--win-per-user-install'
    }
}

Write-Host "Running jpackage..." -ForegroundColor Gray

# For EXE installers, we need to customize WiX to add auto-launch
if ($Type -eq 'exe') {
    # Step 1: Use --temp to preserve WiX files
    $tempWixDir = Join-Path $buildDir 'wix-temp'
    if (Test-Path $tempWixDir) {
        Remove-Item $tempWixDir -Recurse -Force
    }
    
    $tempArgs = $jpackageArgs + @('--temp', $tempWixDir)
    
    Write-Host "Generating installer with WiX customization..." -ForegroundColor Gray
    & $jpackage @tempArgs
    
    if ($LASTEXITCODE -eq 0) {
        # Find and modify main.wxs to add auto-launch
        $mainWxs = Get-ChildItem -Path $tempWixDir -Filter "main.wxs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($mainWxs -and (Test-Path $mainWxs.FullName)) {
            Write-Host "Adding auto-launch feature to installer..." -ForegroundColor Cyan
            
            $wxsContent = Get-Content $mainWxs.FullName -Raw -Encoding UTF8
            
            # Add launch properties and custom action before </Product>
            $launchCode = @"


    <!-- Auto-launch after installation -->
    <Property Id="LAUNCHAPP" Value="1" />
    <Property Id="WixShellExecTarget" Value="[#MonocraftFontTool.exe]" />
    
    <CustomAction Id="LaunchApplication"
                  BinaryKey="WixCA"
                  DllEntry="WixShellExec"
                  Impersonate="yes" />
"@
            
            $wxsContent = $wxsContent -replace '</Product>', "$launchCode`r`n  </Product>"
            
            # Save modified WiX file
            $wxsContent | Out-File -FilePath $mainWxs.FullName -Encoding UTF8 -NoNewline
            
            Write-Success "WiX customization applied to main.wxs"
            
            # Now create a custom ExitDialog with checkbox
            $resourceDir = Join-Path $buildDir 'wix-resources'
            if (!(Test-Path $resourceDir)) {
                New-Item -ItemType Directory -Path $resourceDir -Force | Out-Null
            }
            
            $customExitDialog = Join-Path $resourceDir 'CustomExitDialog.wxs'
            @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Fragment>
    <UI>
      <!-- Override the standard ExitDialog -->
      <Dialog Id="ExitDialog" Width="370" Height="270" Title="[ProductName] Setup">
        <Control Id="Title" Type="Text" X="135" Y="20" Width="220" Height="60" Transparent="yes" NoPrefix="yes" Text="{\WixUI_Font_Title}Installation Complete" />
        <Control Id="Description" Type="Text" X="135" Y="70" Width="220" Height="20" Transparent="yes" NoPrefix="yes" Text="Click Finish to exit the setup." />
        <Control Id="LaunchCheckBox" Type="CheckBox" X="135" Y="120" Width="220" Height="17" Property="LAUNCHAPP" CheckBoxValue="1" Text="Launch Monocraft Font Tool" />
        <Control Id="BottomLine" Type="Line" X="0" Y="234" Width="370" Height="0" />
        <Control Id="Back" Type="PushButton" X="180" Y="243" Width="56" Height="17" Disabled="yes" Text="&amp;Back" />
        <Control Id="Finish" Type="PushButton" X="236" Y="243" Width="56" Height="17" Default="yes" Cancel="yes" Text="&amp;Finish">
          <Publish Event="DoAction" Value="LaunchApplication">LAUNCHAPP = 1</Publish>
          <Publish Event="EndDialog" Value="Return">1</Publish>
        </Control>
        <Control Id="Cancel" Type="PushButton" X="304" Y="243" Width="56" Height="17" Disabled="yes" Text="Cancel" />
        <Control Id="Bitmap" Type="Bitmap" X="0" Y="0" Width="370" Height="234" TabSkip="no" Text="!(loc.InstallDirDlgBannerBitmap)" />
      </Dialog>
    </UI>
  </Fragment>
</Wix>
"@ | Out-File -FilePath $customExitDialog -Encoding UTF8
            
            Write-Host "Created custom ExitDialog override with launch checkbox" -ForegroundColor Gray
            
            # Modify ui.wxf to reference our custom dialog
            $uiWxf = Get-ChildItem -Path $tempWixDir -Filter "ui.wxf" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            
            if ($uiWxf -and (Test-Path $uiWxf.FullName)) {
                $uiContent = Get-Content $uiWxf.FullName -Raw -Encoding UTF8
                
                Write-Host "Adding ExitDialog override reference to UI..." -ForegroundColor Gray
                
                # Add DialogRef for our ExitDialog override (will replace the standard one)
                $dialogRef = '      <DialogRef Id="ExitDialog"></DialogRef>'
                if ($uiContent -notmatch 'DialogRef Id="ExitDialog"') {
                    # Insert after the UIRef for WixUI_InstallDir
                    $uiContent = $uiContent -replace '(<UIRef Id="WixUI_InstallDir"></UIRef>)', "`$1`r`n$dialogRef"
                }
                
                $uiContent | Out-File -FilePath $uiWxf.FullName -Encoding UTF8 -NoNewline
                Write-Host "UI configured with ExitDialog override" -ForegroundColor Gray
            }
            
            # Copy custom dialog to wix-temp config directory so it gets compiled
            $configDir = Join-Path $tempWixDir 'config'
            Copy-Item $customExitDialog -Destination $configDir -Force
            Write-Host "Copied CustomExitDialog to build config" -ForegroundColor Gray
            
        } else {
            Write-Warning "Could not find main.wxs for customization"
        }
    }
} else {
    # For non-EXE types, just run jpackage normally
    & $jpackage @jpackageArgs
}

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
