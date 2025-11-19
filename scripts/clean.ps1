# Clean build artifacts

# Run with .\scripts\clean.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$buildDir = Join-Path $projectRoot 'build'

Write-Host 'Cleaning build artifacts...'

# Delete .class files
Get-ChildItem -Path $projectRoot -Filter *.class -Recurse | Remove-Item -Force
Write-Host 'Deleted .class files'

# Clean build directory contents but keep the folder
if (Test-Path $buildDir) {
    Get-ChildItem -Path $buildDir -Recurse | Remove-Item -Force -Recurse
    Write-Host 'Cleaned build/ directory contents'
}

# Delete EXE file
$exeFile = Join-Path $projectRoot 'Monocraft Font Tool for VSC.exe'
if (Test-Path $exeFile) {
    Remove-Item $exeFile -Force
    Write-Host 'Deleted EXE file'
}

# Also delete old EXE names if they exist
$oldExeFile1 = Join-Path $projectRoot 'MinecraftFontInstaller.exe'
if (Test-Path $oldExeFile1) {
    Remove-Item $oldExeFile1 -Force
    Write-Host 'Deleted old EXE file (MinecraftFontInstaller.exe)'
}

$oldExeFile2 = Join-Path $projectRoot 'VSCodeFontTool.exe'
if (Test-Path $oldExeFile2) {
    Remove-Item $oldExeFile2 -Force
    Write-Host 'Deleted old EXE file (VSCodeFontTool.exe)'
}

# Old files that might exist in root (no longer needed with build/ folder)
$oldConfigFile = Join-Path $projectRoot 'launch4j-config.xml'
if (Test-Path $oldConfigFile) {
    Remove-Item $oldConfigFile -Force
    Write-Host 'Deleted old launch4j-config.xml from root'
}

$oldLogFile = Join-Path $projectRoot 'launch4j.log'
if (Test-Path $oldLogFile) {
    Remove-Item $oldLogFile -Force
    Write-Host 'Deleted old launch4j.log from root'
}

$oldManifestFile = Join-Path $projectRoot 'manifest.txt'
if (Test-Path $oldManifestFile) {
    Remove-Item $oldManifestFile -Force
    Write-Host 'Deleted old manifest.txt from root'
}

$oldJarFile = Join-Path $projectRoot 'MonocraftFontInstaller.jar'
if (Test-Path $oldJarFile) {
    Remove-Item $oldJarFile -Force
    Write-Host 'Deleted old JAR file from root'
}

# Optional: uncomment to also delete generated icon
# $iconFile = Join-Path $projectRoot 'app-icon.ico'
# if (Test-Path $iconFile) {
#     Remove-Item $iconFile -Force
#     Write-Host 'Deleted app-icon.ico'
# }

Write-Host 'Clean complete!'

# Explicitly exit with success code
exit 0
