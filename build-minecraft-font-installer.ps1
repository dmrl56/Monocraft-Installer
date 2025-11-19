# This PowerShell script automates the process of compiling, packaging, and preparing a Windows EXE from your Java project using Launch4j.
# Adjust paths as needed for your environment.

# Run with .\build-minecraft-font-installer.ps1

# Set variables
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$srcDir = Join-Path $projectRoot 'com\beispiel'
$mainJava = Join-Path $srcDir 'MinecraftFontInstaller.java'
$classDir = $projectRoot
$jarName = 'MinecraftFontInstaller.jar'
$jarPath = Join-Path $projectRoot $jarName
$manifest = Join-Path $projectRoot 'manifest.txt'
$launch4jConfig = Join-Path $projectRoot 'launch4j-config.xml'
$exeName = 'Minecraft Font Tool for VSC.exe'
$exePath = Join-Path $projectRoot $exeName

# 1. Compile Java code
Write-Host 'Compiling Java source...'
javac $mainJava
if ($LASTEXITCODE -ne 0) { Write-Error 'Java compilation failed.'; exit 1 }

# 2. Create JAR file with manifest
Write-Host 'Creating JAR file...'
if (!(Test-Path $manifest)) {
    # Create a default manifest if not present
    Set-Content -Path $manifest -Value "Main-Class: com.beispiel.MinecraftFontInstaller`r`n"
}
jar cfm $jarName $manifest -C $classDir com
if ($LASTEXITCODE -ne 0) { Write-Error 'JAR creation failed.'; exit 1 }

# 3. Create Launch4j config if not present
if (!(Test-Path $launch4jConfig)) {
    $launch4jXml = @"
<launch4jConfig>
  <dontWrapJar>false</dontWrapJar>
  <headerType>gui</headerType>
  <jar>$jarPath</jar>
  <outfile>$exePath</outfile>
  <errTitle>VS Code Font Tool</errTitle>
  <jarArgs></jarArgs>
  <chdir>.</chdir>
  <priority>normal</priority>
  <downloadUrl>https://adoptium.net/</downloadUrl>
  <supportUrl></supportUrl>
  <stayAlive>false</stayAlive>
  <restartOnCrash>false</restartOnCrash>
  <icon></icon>
  <singleInstance>
    <mutexName>VSCodeFontTool</mutexName>
    <windowTitle></windowTitle>
  </singleInstance>
  <versionInfo>
    <fileVersion>1.0.0.0</fileVersion>
    <txtFileVersion>1.0.0</txtFileVersion>
    <fileDescription>VS Code Font Configuration</fileDescription>
    <copyright>Copyright 2025</copyright>
    <productVersion>1.0.0.0</productVersion>
    <txtProductVersion>1.0.0</txtProductVersion>
    <productName>VS Code Font Tool</productName>
    <internalName>VSCodeFontTool</internalName>
    <originalFilename>VSCodeFontTool.exe</originalFilename>
  </versionInfo>
  <jre>
    <minVersion>11</minVersion>
    <maxVersion></maxVersion>
    <jdkPreference>preferJre</jdkPreference>
    <bundledJre64Bit>false</bundledJre64Bit>
  </jre>
</launch4jConfig>
"@
    # Save as UTF8 without BOM which Launch4j prefers
    $launch4jXml | Out-File -FilePath $launch4jConfig -Encoding utf8
    Write-Host 'Default Launch4j config created. Edit launch4j-config.xml as needed.'
}


# 4. Run Launch4j using absolute path
Write-Host 'Packaging EXE with Launch4j...'
Write-Host 'Packaging EXE with Launch4j...'

# small pause to ensure file handles are released
Start-Sleep -Milliseconds 300

# Run Launch4j and capture output
$launch4jExe = 'C:\Program Files (x86)\Launch4j\launch4j.exe'
$logFile = Join-Path $projectRoot 'launch4j.log'
& $launch4jExe $launch4jConfig *>&1 | Tee-Object -FilePath $logFile
if ($LASTEXITCODE -ne 0) {
  Write-Error "Launch4j packaging failed. See $logFile for details."
  Get-Content $logFile | Write-Host
  exit 1
}

Write-Host 'Build complete! You can now distribute' $exeName
