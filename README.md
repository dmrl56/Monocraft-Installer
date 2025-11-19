# Monocraft Font Tool for VS Code

**A modern, user-friendly Windows GUI to install Monocraft fonts and configure Visual Studio Code font settings in one click.**

---

## Features

- **Add/Remove Monocraft Font**: Instantly toggle Monocraft font in VS Code settings
- **Install/Uninstall Fonts**: Install Monocraft fonts for the current user (no admin rights required)
- **Bundled Fonts**: Fonts are embedded for single-file distribution
- **User-Level Installation**: No UAC prompts or administrator privileges needed
- **Smart Settings Management**: Preserves your existing VS Code settings structure
- **Modern, Maintainable Codebase**: Modular Java code with clear separation of concerns

---

## How It Works

### Main Actions

- **Install Fonts**: Copies Monocraft font files to `%LOCALAPPDATA%\Microsoft\Windows\Fonts` and registers them for the current user (no admin required). Fonts are available immediately (restart VS Code if needed).
- **Uninstall Fonts**: Removes Monocraft fonts from your user fonts folder and registry.
- **Add Monocraft Font**: Updates your VS Code `settings.json` to use Monocraft fonts:
  ```json
  {
    "editor.fontFamily": "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "terminal.integrated.fontFamily": "Monocraft Nerd Font"
  }
  ```
- **Remove Monocraft Font**: Restores your previous VS Code font settings.

---

## Quick Start

### For Users

1. **Download** the latest executable: `Monocraft Font Tool for VSC.exe`
2. **Run** the application (no installation needed)
3. Click **Install Fonts** to install the Monocraft fonts
4. Click **Add Monocraft Font** to configure VS Code
5. Restart VS Code to see the changes

### For Developers

#### Build from Source

**Requirements:**
- Windows 10/11
- JDK 11 or higher
- [Launch4j](https://launch4j.sourceforge.net/) installed at `C:\Program Files (x86)\Launch4j\`

**Build steps:**
```powershell
# Clone or download this repository
cd vsc-mc-script

# (Optional) Create an icon
.\scripts\create-icon.ps1

# Build the executable
.\scripts\rebuild.ps1
```
The output will be: `Monocraft Font Tool for VSC.exe`

---

## Code Structure

```
vsc-mc-script/
├── src/
│   └── com/example/
│       ├── MonocraftFontInstaller.java   # Entry point (main class)
│       ├── MainWindow.java               # GUI components and event handlers
│       ├── FontInstaller.java            # Font installation/uninstallation logic
│       ├── SettingsManager.java          # VS Code settings.json manipulation
│       ├── FileUtils.java                # File copy utility
│       └── SystemUtils.java              # System command execution
├── scripts/
│   ├── build.ps1                         # Main build script
│   ├── clean.ps1                         # Clean artifacts
│   ├── rebuild.ps1                       # Clean + Build
│   └── create-icon.ps1                   # Generate app icon
├── resources/
│   └── fonts/
│       └── Monocraft-font/
│           ├── Monocraft-nerd-fonts-patched.ttc
│           └── Monocraft.ttf
├── build/
│   ├── classes/
│   │   └── com/example/
│       │       ├── MonocraftFontInstaller.class
│       │       ├── MainWindow.class
│       │       ├── FontInstaller.class
│   │       ├── SettingsManager.class
│   │       ├── FileUtils.class
│   │       └── SystemUtils.class
│   ├── MonocraftFontInstaller.jar
│   ├── manifest.txt
│   ├── launch4j-config.xml
│   └── launch4j.log
└── docs/                                 # Documentation
```

---

## Documentation

See the [`docs/`](./docs/) folder for detailed documentation, usage tips, and troubleshooting.

---

## Build Scripts

### `.\scripts\rebuild.ps1`
Clean build from scratch (recommended)

### `.\scripts\build.ps1`
Compile, package JAR, and create EXE with Launch4j

### `.\scripts\clean.ps1`
Remove all build artifacts (.class, .jar, .exe, configs)

### `.\scripts\create-icon.ps1`
Generate a Minecraft-style icon for the application

---

## Packaging Features

### Version Information
The EXE includes proper Windows version metadata:
- **Version**: 1.3.1.0
- **Product Name**: Monocraft Font Tool for VS Code
- **Description**: Monocraft Font Configuration Tool for Visual Studio Code

View by right-clicking the EXE → Properties → Details tab

### Icon Support
The build script automatically includes `app-icon.ico` if present. Create one with:
```powershell
.\scripts\create-icon.ps1
```

### Bundled Fonts
Fonts are automatically bundled into the JAR during build if the `resources/fonts/Monocraft-font` folder exists. The app extracts them at runtime, so you can distribute a single EXE file.

---

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

---

## Requirements

- **Windows 10/11** (tested on Windows 11)
- **Java Runtime Environment (JRE) 11+** (automatically detected, prompts for download if missing)
- **Visual Studio Code** (for font configuration features)

---

## Troubleshooting

### Fonts don't appear in VS Code
- Restart VS Code completely
- If still not visible, sign out and back in to Windows
- Check font installation: Windows Settings → Personalization → Fonts

### "Font files not found" error
- Ensure `resources/fonts/Monocraft-font` folder is present (if fonts not bundled)
- Or rebuild with fonts bundled: `.\scripts\rebuild.ps1`

### Settings not applied
- Close VS Code before clicking "Add Minecraft Font"
- Check `settings.json` manually at: `%APPDATA%\Roaming\Code\User\settings.json`
- Verify no syntax errors in the file

### Build fails
- Ensure JDK is in PATH: `java -version` and `javac -version`
- Check Launch4j installed at: `C:\Program Files (x86)\Launch4j\`
- Run as Administrator if file permission errors occur

---

## Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

For more details, see the [CONTRIBUTING.md](CONTRIBUTING.md) file.

---

## License

This project is licensed under the MIT License.

---

## Credits

- **Monocraft Font**: [Monocraft by IdreesInc](https://github.com/IdreesInc/Monocraft)
- **Launch4j**: [SourceForge Launch4j](https://launch4j.sourceforge.net/)
