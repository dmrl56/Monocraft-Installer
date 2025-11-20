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

1. **Download** the latest installer: [`MonocraftFontTool-1.3.3.exe`](https://github.com/dmrl56/Monocraft-Installer/releases)
2. **Run** the installer and follow the setup wizard
3. **Complete installation** - The application will launch automatically when you click "Finish"
4. Click **Install Fonts** to install the Monocraft fonts
5. Click **Add Monocraft Font** to configure VS Code
6. Restart VS Code to see the changes

**No Java installation required!** The installer bundles everything you need.

### For Developers

#### Build from Source

**Requirements:**
- Windows 10/11
- JDK 17 or higher (includes jpackage for native packaging)
- WiX Toolset 3.14+ (for installer builds - install via `scoop install versions/wixtoolset3`)

**Default Build Method: Windows Installer (Recommended)**

This creates a single-file installer that works on any Windows PC without requiring Java.

```powershell
# Clone or download this repository
cd vsc-mc-script

# (Optional) Create an icon
.\scripts\create-icon.ps1

# Build the installer (default: single-file .exe installer)
.\scripts\rebuild.ps1

# Output: build\package\MonocraftFontTool-1.3.3.exe (42 MB)
# Upload this single file to GitHub releases
```

**Alternative package types:**
```powershell
.\scripts\rebuild.ps1 -PackageType app-image  # Portable folder (no installer)
.\scripts\rebuild.ps1 -PackageType msi        # MSI installer
```

**Alternative Build Method: Launch4j Wrapper (smaller, requires Java on target)**

For users who already have Java 11+ installed:

```powershell
# Build with Launch4j wrapper
.\scripts\rebuild-launch4j.ps1

# Output: Monocraft Font Tool for VSC.exe (~2 MB, requires Java 11+ on target)
```

Note: Launch4j requires [Launch4j](https://launch4j.sourceforge.net/) installed at `C:\Program Files (x86)\Launch4j\`

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

### `.\scripts\rebuild.ps1` (Default - Recommended)
Clean build from scratch using jpackage to create Windows installer with bundled JRE
- No Java required on target machine
- Single-file installer (42 MB)
- Supports: `-PackageType exe` (default), `-PackageType app-image`, `-PackageType msi`

### `.\scripts\build.ps1`
Compile Java, create JAR, and package with jpackage (called by rebuild.ps1)

### `.\scripts\package.ps1`
Create native package with bundled JRE using jpackage (JDK 17+ required)
- `-Type exe` - Windows installer (default)
- `-Type app-image` - Portable folder with EXE and runtime
- `-Type msi` - MSI installer (requires WiX Toolset)

### `.\scripts\rebuild-launch4j.ps1` (Alternative)
Clean build using Launch4j wrapper
- Small file size (~1-2 MB)
- Requires Java 11+ on target machine
- Requires Launch4j installed

### `.\scripts\build-launch4j.ps1` (Alternative)
Compile and package with Launch4j (called by rebuild-launch4j.ps1)

### `.\scripts\clean.ps1`
Remove all build artifacts (.class, .jar, .exe, configs)

### `.\scripts\create-icon.ps1`
Generate a Minecraft-style icon for the application

### `.\scripts\sign.ps1`
Sign the EXE/installer with a code-signing certificate (optional, for trusted distribution)

---

## Packaging Features

### Distribution Methods

**Windows Installer with jpackage (Default - Recommended):**
- Single-file installer (42 MB)
- **No Java required** on user's computer - everything is bundled
- Professional installer with Start Menu shortcuts and uninstaller
- **Auto-launch** - Application starts automatically after installation
- Directory chooser - Users can select installation location
- Best for general distribution to end users
- Upload single file to GitHub releases
- Build with: `.\scripts\rebuild.ps1`

**Portable Folder (Alternative 1):**
- Folder with EXE and bundled runtime (~50-60 MB total)
- No installation required, just extract and run
- No Java required on user's computer
- Build with: `.\scripts\rebuild.ps1 -PackageType app-image`

**Launch4j Wrapper (Alternative 2):**
- Small EXE size (~2 MB)
- Requires Java 11+ installed on user's computer
- Good for users who already have Java
- Build with: `.\scripts\rebuild-launch4j.ps1`

### Version Information
The EXE includes proper Windows version metadata:
- **Version**: 1.3.3.0
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
