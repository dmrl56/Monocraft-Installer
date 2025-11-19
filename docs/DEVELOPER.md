# Developer Guide — Monocraft Font Tool for VS Code

## Project Structure

```
vsc-mc-script/
├── src/com/example/
│   ├── MonocraftFontInstaller.java   # Entry point
│   ├── MainWindow.java               # GUI components
│   ├── FontInstaller.java            # Font install/uninstall logic
│   ├── SettingsManager.java          # VS Code settings logic
│   ├── FileUtils.java                # File copy utility
│   └── SystemUtils.java              # System command execution
├── scripts/
│   ├── build.ps1                     # Build script
│   ├── clean.ps1                     # Clean script
│   ├── rebuild.ps1                   # Clean + build
│   └── create-icon.ps1               # Icon generator
├── resources/fonts/Monocraft-font/   # Font files
├── build/                            # Build artifacts
└── docs/                             # Documentation
```

## Build Instructions

- **Requirements:**
  - Windows 10/11
  - JDK 11 or higher
  - [Launch4j](https://launch4j.sourceforge.net/) at `C:\Program Files (x86)\Launch4j\`

- **Build:**
  ```powershell
  .\scripts\rebuild.ps1
  ```
  Output: `Monocraft Font Tool for VSC.exe`

## Code Overview

- **MonocraftFontInstaller.java** — Entry point, launches GUI
- **MainWindow.java** — All GUI logic and event handlers
- **FontInstaller.java** — Font install/uninstall, registry, extraction
- **SettingsManager.java** — VS Code settings.json manipulation
- **FileUtils.java** — File copy with retry
- **SystemUtils.java** — System command execution

## Packaging
- Fonts are bundled in the JAR and copied at runtime
- EXE is generated with Launch4j, version info is set in `build.ps1`

## Contributing
- Fork, branch, and PR as usual
- Keep code modular and well-documented
- Update docs/ as needed
