# This PowerShell script automates the process of compiling, packaging, and preparing a Windows EXE from your Java project using Launch4j.
# Adjust paths as needed for your environment.

# Run with .\scripts\build.ps1

# Set variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$srcDir = Join-Path $projectRoot 'src'
$mainJava = Join-Path $srcDir 'com\beispiel\MonocraftFontInstaller.java'
$buildDir = Join-Path $projectRoot 'build'
$classDir = Join-Path $buildDir 'classes'
$jarName = 'MonocraftFontInstaller.jar'
$jarPath = Join-Path $buildDir $jarName
$manifest = Join-Path $buildDir 'manifest.txt'
$launch4jConfig = Join-Path $buildDir 'launch4j-config.xml'
$exeName = 'Monocraft Font Tool for VSC.exe'
$exePath = Join-Path $projectRoot $exeName

# Ensure build directory exists
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    Write-Host 'Created build directory' -ForegroundColor Gray
}
if (!(Test-Path $classDir)) {
    New-Item -ItemType Directory -Path $classDir -Force | Out-Null
}

# 1. Compile Java code
Write-Host 'Compiling Java source...'
javac -d $classDir $mainJava
if ($LASTEXITCODE -ne 0) { Write-Error 'Java compilation failed.'; exit 1 }

# Check for icon
$iconPath = Join-Path $projectRoot 'app-icon.ico'
if (Test-Path $iconPath) {
    Write-Host 'Found icon file: app-icon.ico' -ForegroundColor Green
} else {
    Write-Host 'No icon found. Run .\scripts\create-icon.ps1 to create one.' -ForegroundColor Yellow
}

# 2. Create JAR file with manifest
Write-Host 'Creating JAR file...'
if (!(Test-Path $manifest)) {
    # Create a default manifest if not present
    Set-Content -Path $manifest -Value "Main-Class: com.beispiel.MonocraftFontInstaller`r`n"
}
# If Monocraft-font exists, include it in the jar so fonts are bundled
$fontsPath = Join-Path $projectRoot 'resources\fonts\Monocraft-font'
if (Test-Path $fontsPath) {
  Write-Host 'Including Monocraft-font folder in JAR'
  jar cfm $jarPath $manifest -C $classDir com -C (Join-Path $projectRoot 'resources\fonts') Monocraft-font
} else {
  jar cfm $jarPath $manifest -C $classDir com
}
if ($LASTEXITCODE -ne 0) { Write-Error 'JAR creation failed.'; exit 1 }

# 3. Create Launch4j config (always regenerate to ensure latest settings)
$iconPath = Join-Path $projectRoot 'app-icon.ico'
$iconXml = if (Test-Path $iconPath) { "<icon>$iconPath</icon>" } else { "<icon></icon>" }

$launch4jXml = @"
<launch4jConfig>
  <dontWrapJar>false</dontWrapJar>
  <headerType>gui</headerType>
  <jar>$jarPath</jar>
  <outfile>$exePath</outfile>
  <errTitle>Minecraft Font Tool</errTitle>
  <cmdLine></cmdLine>
  <chdir>.</chdir>
  <priority>normal</priority>
  <downloadUrl>https://adoptium.net/</downloadUrl>
  <supportUrl>https://github.com/</supportUrl>
  <stayAlive>false</stayAlive>
  <restartOnCrash>false</restartOnCrash>
  $iconXml
  <manifest></manifest>
  <singleInstance>
    <mutexName>MonocraftFontToolVSC_SingleInstance</mutexName>
    <windowTitle>Monocraft Font Tool for VS Code</windowTitle>
  </singleInstance>
  <versionInfo>
    <fileVersion>1.3.0.0</fileVersion>
    <txtFileVersion>1.3.0</txtFileVersion>
    <fileDescription>Monocraft Font Configuration Tool for Visual Studio Code</fileDescription>
    <copyright>Copyright © 2025</copyright>
    <productVersion>1.3.0.0</productVersion>
    <txtProductVersion>1.3.0</txtProductVersion>
    <productName>Monocraft Font Tool for VS Code</productName>
    <companyName></companyName>
    <internalName>MonocraftFontTool</internalName>
    <originalFilename>Monocraft Font Tool for VSC.exe</originalFilename>
    <trademarks></trademarks>
    <language>ENGLISH_US</language>
  </versionInfo>
  <jre>
    <path></path>
    <bundledJre64Bit>false</bundledJre64Bit>
    <bundledJreAsFallback>false</bundledJreAsFallback>
    <minVersion>11</minVersion>
    <maxVersion></maxVersion>
    <jdkPreference>preferJre</jdkPreference>
    <runtimeBits>64/32</runtimeBits>
  </jre>
</launch4jConfig>
"@
# Save as UTF8 without BOM which Launch4j prefers
$launch4jXml | Out-File -FilePath $launch4jConfig -Encoding utf8
Write-Host 'Launch4j config generated with version 1.3.0'


# 4. Run Launch4j using absolute path
Write-Host 'Packaging EXE with Launch4j...'
Write-Host 'Packaging EXE with Launch4j...'

# small pause to ensure file handles are released
Start-Sleep -Milliseconds 300

# Run Launch4j and capture output
$launch4jExe = 'C:\Program Files (x86)\Launch4j\launch4j.exe'
$logFile = Join-Path $buildDir 'launch4j.log'
& $launch4jExe $launch4jConfig *>&1 | Tee-Object -FilePath $logFile
if ($LASTEXITCODE -ne 0) {
  Write-Error "Launch4j packaging failed. See $logFile for details."
  Get-Content $logFile | Write-Host
  exit 1
}

Write-Host 'Build complete! You can now distribute' $exeName
