# Monocraft Font Tool for VS Code

A simple Windows GUI tool to install Monocraft fonts and configure Visual Studio Code font settings with one click.

## Features

- ✅ **Add/Remove Monocraft Font**: Toggle Monocraft font in VS Code settings with one button
- 🎨 **Install/Uninstall Fonts**: Install Monocraft fonts for the current user (no admin rights required)
- 📦 **Bundled Fonts**: Fonts can be embedded in the executable for single-file distribution
- 🎯 **User-Level Installation**: No UAC prompts or administrator privileges needed
- 🔄 **Smart Settings Management**: Preserves your existing VS Code settings structure

## What It Does

### Add Monocraft Font Button
Sets these VS Code settings:
```json
{
  "editor.fontFamily": "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "terminal.integrated.fontFamily": "Monocraft Nerd Font"
}
```

### Install Fonts Button
- Copies font files to: `%LOCALAPPDATA%\Microsoft\Windows\Fonts`
- Registers fonts in user registry: `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts`
- No admin rights required
- Fonts available immediately (may need to restart VS Code)

## Quick Start

### For Users

1. **Download** the executable: `Monocraft Font Tool for VSC.exe`
2. **Run** the application (no installation needed)
3. Click **"Install Fonts"** to install the Monocraft fonts
4. Click **"Add Monocraft Font"** to configure VS Code
5. Restart VS Code to see the changes

### For Developers

#### Build from Source

Requirements:
- Windows 10/11
- JDK 11 or higher
- [Launch4j](https://launch4j.sourceforge.net/) installed at `C:\Program Files (x86)\Launch4j\`

Build steps:
```powershell
# Clone or download this repository
cd vsc-mc-script

# (Optional) Create an icon
.\create-icon.ps1

# Build the executable
.\rebuild.ps1
```

The output will be: `Monocraft Font Tool for VSC.exe`

## Project Structure

```
vsc-mc-script/
├── com/beispiel/
│   └── MonocraftFontInstaller.java    # Main application
├── Monocraft-font/                     # Font files (bundled into JAR)
│   ├── Monocraft-nerd-fonts-patched.ttc
│   └── Monocraft-ttf-otf/other-formats/Monocraft.ttf
├── build-monocraft-font-installer.ps1  # Build script
├── clean.ps1                           # Clean build artifacts
├── rebuild.ps1                         # Clean + Build
├── create-icon.ps1                     # Generate app icon
└── SIGNING.md                          # Code signing guide
```

## Build Scripts

### `.\rebuild.ps1`
Clean build from scratch (recommended)

### `.\build-monocraft-font-installer.ps1`
Compile, package JAR, and create EXE with Launch4j

### `.\clean.ps1`
Remove all build artifacts (.class, .jar, .exe, configs)

### `.\create-icon.ps1`
Generate a Minecraft-style icon for the application

## Packaging Features

### Version Information
The EXE includes proper Windows version metadata:
- **Version**: 1.2.0.0
- **Product Name**: Minecraft Font Tool for VS Code
- **Description**: Minecraft Font Configuration Tool for Visual Studio Code
- **Copyright**: © 2025

View by right-clicking the EXE → Properties → Details tab

### Icon Support
The build script automatically includes `app-icon.ico` if present. Create one with:
```powershell
.\create-icon.ps1
```

### Digital Signing (Optional)
For production distribution, digitally sign the EXE to reduce SmartScreen warnings.

See [SIGNING.md](SIGNING.md) for complete guide. Quick example:
```powershell
signtool sign /a /n "Your Certificate" /t http://timestamp.digicert.com /fd SHA256 "Minecraft Font Tool for VSC.exe"
```

### Bundled Fonts
Fonts are automatically bundled into the JAR during build if the `Monocraft-font` folder exists. The app extracts them at runtime, so you can distribute a single EXE file.

## How It Works

### Settings Management
- Directly edits VS Code's `settings.json` file
- Preserves formatting and existing settings
- Line-aware algorithm maintains JSON structure
- Located at: `%APPDATA%\Roaming\Code\User\settings.json`

### Font Installation
- Extracts fonts from bundled resources (if embedded)
- Falls back to `Monocraft-font` folder if available
- Copies to per-user Fonts directory (no admin required)
- Registers via `HKCU` registry entries
- Verifies successful installation

### Uninstall Process
- Removes font files from user Fonts directory
- Deletes registry entries
- Safe to run multiple times

## Requirements

- **Windows 10/11** (tested on Windows 11)
- **Java Runtime Environment (JRE) 11+** (automatically detected, prompts for download if missing)
- **Visual Studio Code** (for font configuration features)

## Troubleshooting

### Fonts don't appear in VS Code
- Restart VS Code completely
- If still not visible, sign out and back in to Windows
- Check font installation: Windows Settings → Personalization → Fonts

### "Font files not found" error
- Ensure `Monocraft-font` folder is next to the EXE (if fonts not bundled)
- Or rebuild with fonts bundled: `.\rebuild.ps1`

### Settings not applied
- Close VS Code before clicking "Add Minecraft Font"
- Check `settings.json` manually at: `%APPDATA%\Roaming\Code\User\settings.json`
- Verify no syntax errors in the file

### Build fails
- Ensure JDK is in PATH: `java -version` and `javac -version`
- Check Launch4j installed at: `C:\Program Files (x86)\Launch4j\`
- Run as Administrator if file permission errors occur

## Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share with others who use VS Code and like Minecraft fonts!

## License

This tool is provided as-is for personal and educational use.

The Monocraft font is subject to its own license (typically OFL - SIL Open Font License).

## Credits

- **Monocraft Font**: [Monocraft by IdreesInc](https://github.com/IdreesInc/Monocraft)
- **Launch4j**: [SourceForge Launch4j](https://launch4j.sourceforge.net/)

---

**Made with ❤️ for VS Code and Minecraft font enthusiasts**
