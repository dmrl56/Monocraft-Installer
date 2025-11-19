# Pfad zur settings.json
$settingsPath = "C:\Users\dmorl\AppData\Roaming\Code\User\settings.json"

# settings.json einlesen
$settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

# Entferne Minecraft Font-spezifische Einstellungen
$settings.PSObject.Properties.Remove('editor.fontFamily')
$settings.PSObject.Properties.Remove('editor.fontLigatures')
$settings.PSObject.Properties.Remove('terminal.integrated.fontFamily')

# settings.json speichern
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "Minecraft Font-Einstellungen wurden entfernt."
