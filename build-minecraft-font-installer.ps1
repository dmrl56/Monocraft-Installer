# This PowerShell script automates the process of compiling, packaging, and preparing a Windows EXE from your Java project using Launch4j.
# Adjust paths as needed for your environment.

# Set variables
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$srcDir = Join-Path $projectRoot 'com\beispiel'
$mainJava = Join-Path $srcDir 'MinecraftFontInstaller.java'
$classDir = $projectRoot
$jarName = 'MinecraftFontInstaller.jar'
$manifest = Join-Path $projectRoot 'manifest.txt'
$launch4jConfig = Join-Path $projectRoot 'launch4j-config.xml'
$exeName = 'MinecraftFontInstaller.exe'

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
  <jar>$jarName</jar>
  <outfile>$exeName</outfile>
  <errTitle>Minecraft Font Installer</errTitle>
  <jarArgs></jarArgs>
  <chdir>.</chdir>
  <priority>normal</priority>
  <downloadUrl>https://adoptium.net/</downloadUrl>
  <supportUrl></supportUrl>
  <manifest></manifest>
  <icon></icon>
  <jre>
    <minVersion>11</minVersion>
    <maxVersion></maxVersion>
    <jdkPreference>preferJre</jdkPreference>
    <bundledJre64Bit>false</bundledJre64Bit>
  </jre>
</launch4jConfig>
"@
    Set-Content -Path $launch4jConfig -Value $launch4jXml
    Write-Host 'Default Launch4j config created. Edit launch4j-config.xml as needed.'
}


# 4. Run Launch4j using absolute path
Write-Host 'Packaging EXE with Launch4j...'
& 'C:\Program Files (x86)\Launch4j\launch4j.exe' $launch4jConfig
if ($LASTEXITCODE -ne 0) { Write-Error 'Launch4j packaging failed.'; exit 1 }

Write-Host 'Build complete! You can now distribute' $exeName
