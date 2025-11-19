# Pfad zur settings.json (absolut im Benutzerprofil)
$settingsPath = Join-Path $env:USERPROFILE 'AppData\Roaming\Code\User\settings.json'

# settings.json einlesen
$settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

# Minecraft Font-spezifische Einstellungen setzen (mit Add-Member falls nicht vorhanden)
if (-not $settings.PSObject.Properties['editor.fontFamily']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'editor.fontFamily' -Value "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace"
} else {
    $settings.'editor.fontFamily' = "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace"
}

if (-not $settings.PSObject.Properties['editor.fontLigatures']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'editor.fontLigatures' -Value $true
} else {
    $settings.'editor.fontLigatures' = $true
}

if (-not $settings.PSObject.Properties['terminal.integrated.fontFamily']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'terminal.integrated.fontFamily' -Value "Monocraft Nerd Font"
} else {
    $settings.'terminal.integrated.fontFamily' = "Monocraft Nerd Font"
}

# settings.json speichern
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "Minecraft Font-Einstellungen wurden hinzugefügt."
