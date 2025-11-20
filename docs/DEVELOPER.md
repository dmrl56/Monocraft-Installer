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
│   ├── build.ps1                     # Main build script (jpackage)
│   ├── build-launch4j.ps1            # Alternative Launch4j build
│   ├── clean.ps1                     # Clean script
│   ├── rebuild.ps1                   # Clean + build (jpackage)
│   ├── rebuild-launch4j.ps1          # Clean + build (Launch4j)
│   ├── package.ps1                   # jpackage wrapper
│   └── create-icon.ps1               # Icon generator
├── resources/fonts/Monocraft-font/   # Font files
├── build/                            # Build artifacts
└── docs/                             # Documentation
```

## Build Instructions

- **Requirements:**
  - Windows 10/11
  - JDK 17 or higher (includes jpackage)
  - WiX Toolset 3.14+ (for installer builds - `scoop install versions/wixtoolset3`)

- **Default Build (jpackage - Recommended):**
  ```powershell
  .\scripts\rebuild.ps1
  ```
  Output: `build\package\MonocraftFontTool-1.3.4.exe` single-file installer (50 MB, no Java required on target)

- **Alternative Package Types:**
  ```powershell
  .\scripts\rebuild.ps1 -PackageType app-image  # Portable folder
  .\scripts\rebuild.ps1 -PackageType msi        # MSI installer
  ```

- **Alternative Build (Launch4j):**
  Requires: [Launch4j](https://launch4j.sourceforge.net/) at `C:\Program Files (x86)\Launch4j\`
  ```powershell
  .\scripts\rebuild-launch4j.ps1
  ```
  Output: `Monocraft Font Tool for VSC.exe` (~2 MB, requires Java 11+ on target)

## Code Overview

- **MonocraftFontInstaller.java** — Entry point, launches GUI
- **MainWindow.java** — All GUI logic and event handlers
- **FontInstaller.java** — Font install/uninstall, registry, extraction
- **SettingsManager.java** — VS Code settings.json manipulation
- **FileUtils.java** — File copy with retry
- **SystemUtils.java** — System command execution

## Packaging
- **Default (jpackage installer):** Fonts are bundled in the JAR, JRE is bundled with the app using jlink+jpackage, creates Windows installer EXE with Start Menu shortcuts. Installer includes auto-launch checkbox (pre-checked) to run the app immediately after installation and directory chooser for custom install location.
- **Alternative 1 (jpackage app-image):** Same as above but creates portable folder instead of installer
- **Alternative 2 (Launch4j):** Fonts are bundled in the JAR and wrapped in an EXE, version info set in `build-launch4j.ps1`, requires Java on target

## Contributing
- Fork, branch, and PR as usual
- Keep code modular and well-documented
- Update docs/ as needed
