# Clean build artifacts

# Run with .\clean.ps1

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host 'Cleaning build artifacts...'

# Delete .class files
Get-ChildItem -Path $projectRoot -Filter *.class -Recurse | Remove-Item -Force
Write-Host 'Deleted .class files'

# Delete JAR file
$jarFile = Join-Path $projectRoot 'MinecraftFontInstaller.jar'
if (Test-Path $jarFile) {
    Remove-Item $jarFile -Force
    Write-Host 'Deleted JAR file'
}

# Delete EXE file
$exeFile = Join-Path $projectRoot 'Minecraft Font Tool for VSC.exe'
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

# Delete Launch4j config
$configFile = Join-Path $projectRoot 'launch4j-config.xml'
if (Test-Path $configFile) {
    Remove-Item $configFile -Force
    Write-Host 'Deleted launch4j-config.xml'
}

# Delete launch4j log
$logFile = Join-Path $projectRoot 'launch4j.log'
if (Test-Path $logFile) {
    Remove-Item $logFile -Force
    Write-Host 'Deleted launch4j.log'
}

# Delete manifest
$manifestFile = Join-Path $projectRoot 'manifest.txt'
if (Test-Path $manifestFile) {
    Remove-Item $manifestFile -Force
    Write-Host 'Deleted manifest.txt'
}

# Optional: uncomment to also delete generated icon
# $iconFile = Join-Path $projectRoot 'app-icon.ico'
# if (Test-Path $iconFile) {
#     Remove-Item $iconFile -Force
#     Write-Host 'Deleted app-icon.ico'
# }

Write-Host 'Clean complete!'
