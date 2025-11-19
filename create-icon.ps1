# Simple script to create a basic icon for the application
# This creates a 256x256 pixel icon with a Minecraft-style block design

$iconPath = Join-Path $PSScriptRoot 'app-icon.ico'

# Check if icon already exists
if (Test-Path $iconPath) {
    Write-Host "Icon already exists at: $iconPath" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -ne 'y') {
        Write-Host "Cancelled."
        exit 0
    }
}

Write-Host "Creating icon file..." -ForegroundColor Cyan

# Load required assemblies for image creation
Add-Type -AssemblyName System.Drawing

# Create a 256x256 bitmap
$size = 256
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Set high quality rendering
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Fill background (dark gray/Minecraft stone)
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 60, 60))
$graphics.FillRectangle($bgBrush, 0, 0, $size, $size)

# Draw a Minecraft-style block/letter (simplified "M" or block design)
$blockColor = [System.Drawing.Color]::FromArgb(87, 166, 74)  # Minecraft grass green
$blockBrush = New-Object System.Drawing.SolidBrush($blockColor)

# Draw pixelated blocks to form a stylized "M" or font symbol
$blockSize = 32
$margin = 32

# Left pillar
$graphics.FillRectangle($blockBrush, $margin, $margin, $blockSize, $size - 2*$margin)
# Right pillar  
$graphics.FillRectangle($blockBrush, $size - $margin - $blockSize, $margin, $blockSize, $size - 2*$margin)
# Middle peak (M shape)
$graphics.FillRectangle($blockBrush, $margin + $blockSize + 16, $margin, $blockSize, $blockSize * 3)
$graphics.FillRectangle($blockBrush, $size - $margin - 2*$blockSize - 16, $margin, $blockSize, $blockSize * 3)

# Add highlight to make it look 3D
$highlightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 200, 110))
$graphics.FillRectangle($highlightBrush, $margin, $margin, $blockSize, $blockSize/4)

# Add text "MC" in center
$font = New-Object System.Drawing.Font("Arial", 64, [System.Drawing.FontStyle]::Bold)
$textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$textFormat = New-Object System.Drawing.StringFormat
$textFormat.Alignment = [System.Drawing.StringAlignment]::Center
$textFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
$rect = New-Object System.Drawing.RectangleF(0, $size/2 - 40, $size, 80)
$graphics.DrawString("MC", $font, $textBrush, $rect, $textFormat)

# Save as PNG first
$tempPng = Join-Path $env:TEMP 'temp-icon.png'
$bitmap.Save($tempPng, [System.Drawing.Imaging.ImageFormat]::Png)

# Dispose graphics objects
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Converting to ICO format..." -ForegroundColor Cyan

# Convert PNG to ICO using a simple method
# For production, consider using a dedicated tool like ImageMagick or online converter
try {
    # Try to use built-in method if available
    $img = [System.Drawing.Image]::FromFile($tempPng)
    $icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]$img).GetHicon())
    $fileStream = [System.IO.File]::Create($iconPath)
    $icon.Save($fileStream)
    $fileStream.Close()
    $img.Dispose()
    
    Write-Host "Icon created successfully at: $iconPath" -ForegroundColor Green
    Write-Host "Icon size: 256x256 pixels" -ForegroundColor Gray
} catch {
    Write-Host "Error creating ICO file: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Convert the PNG manually" -ForegroundColor Yellow
    Write-Host "1. PNG saved at: $tempPng"
    Write-Host "2. Use an online converter (e.g., https://convertio.co/png-ico/)"
    Write-Host "3. Save as: app-icon.ico"
    Write-Host "4. Place in project root"
    exit 1
}

# Clean up temp file
if (Test-Path $tempPng) {
    Remove-Item $tempPng -Force
}

Write-Host ""
Write-Host "Rebuild the project to include the icon in your EXE:" -ForegroundColor Cyan
Write-Host "  .\rebuild.ps1" -ForegroundColor White
