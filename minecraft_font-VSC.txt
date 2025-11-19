# Pfad zur settings.json
$settingsPath = "C:\Users\dmorl\AppData\Roaming\Code\User\settings.json"

# JSON-Inhalt als mehrzeiliger String
$jsonInhalt = @'
{
    "files.autoSave": "afterDelay",
    "redhat.telemetry.enabled": true,
    "security.workspace.trust.untrustedFiles": "open",
    "explorer.confirmDragAndDrop": false,
    "github.copilot.nextEditSuggestions.enabled": true,
    "terminal.external.windowsExec": "C:\\Program Files\\Git\\git-bash.exe",
    "markdown-preview-enhanced.previewTheme": "github-dark.css",
    "markdown-preview-enhanced.codeBlockTheme": "github-dark.css",
    "markdown-preview-enhanced.revealjsTheme": "black.css",
    "markdown-preview-enhanced.enablePreviewZenMode": true,
    "editor.fontFamily": "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "terminal.integrated.fontFamily": "Monocraft Nerd Font"
}
'@

# Inhalt in die Datei schreiben (überschreiben oder neu erstellen)
Set-Content -Path $settingsPath -Value $jsonInhalt -Encoding UTF8

Write-Host "Die settings.json wurde erfolgreich überschrieben."
