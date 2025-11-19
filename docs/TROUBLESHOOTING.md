# Troubleshooting — Monocraft Font Tool for VS Code

## Common Issues

### Fonts not appearing in VS Code
- Restart VS Code after installing fonts
- Make sure you clicked **Add Monocraft Font**
- Check `%APPDATA%\Code\User\settings.json` for correct font settings
- Try rebooting your computer if fonts still do not show

### File in use / Cannot overwrite font file
- Close any applications (including VS Code or font viewers) that may be using the Monocraft font
- Retry the operation

### Settings not updating
- Ensure VS Code is closed when modifying settings
- Check for syntax errors in `settings.json`
- If you have VS Code Insiders, settings may be in a different folder

### EXE fails to launch
- Make sure you are on Windows 10/11
- Ensure you have a supported JRE (Java 11+)
- If you see antivirus warnings, try signing the EXE or use the JAR directly

## Where to Get Help
- See [USAGE.md](./USAGE.md) for step-by-step instructions
- See [DEVELOPER.md](./DEVELOPER.md) for build and code info
- Open an issue on the project repository for further help
