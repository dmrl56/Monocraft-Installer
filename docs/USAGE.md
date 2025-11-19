# Monocraft Font Tool for VS Code — Usage Guide

## Overview
This tool provides a simple way to install/uninstall Monocraft fonts and configure Visual Studio Code to use them, all via a modern Windows GUI. No admin rights required.

## Main Features
- **Install Fonts**: Installs Monocraft fonts for the current user (no UAC prompt)
- **Uninstall Fonts**: Removes Monocraft fonts from your user fonts folder
- **Add Monocraft Font**: Updates VS Code settings.json to use Monocraft fonts
- **Remove Monocraft Font**: Restores your previous VS Code font settings

## How to Use
1. **Download** and run `Monocraft Font Tool for VSC.exe` (no installation needed)
2. Click **Install Fonts** to install the fonts
3. Click **Add Monocraft Font** to configure VS Code
4. To revert, use **Uninstall Fonts** and **Remove Monocraft Font**
5. Restart VS Code to see changes

## Troubleshooting
- If fonts do not appear, restart VS Code and/or your computer
- If you see file-in-use errors, close any apps using the font and try again
- For settings issues, check `%APPDATA%\Code\User\settings.json`

## Advanced
- All actions are user-level (no admin rights needed)
- Fonts are copied to `%LOCALAPPDATA%\Microsoft\Windows\Fonts`
- Registry keys are set under `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts`

## See Also
- [Project README](../README.md)
- [Developer Guide](./DEVELOPER.md)
