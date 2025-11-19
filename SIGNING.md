# Digital Signing Guide for Minecraft Font Tool

Digital signing your EXE helps reduce Windows SmartScreen warnings and builds trust with users.

## Why Sign Your Executable?

- **Reduces SmartScreen warnings**: Signed executables are less likely to trigger Windows Defender SmartScreen
- **Verifies authenticity**: Users can verify the publisher identity
- **Prevents tampering**: Signatures invalidate if the file is modified
- **Professional appearance**: Shows publisher information in Windows properties

## Prerequisites

You need a **Code Signing Certificate**. Options:

### Option 1: Purchase a Certificate (Recommended for Distribution)
- **Commercial CAs**: DigiCert, Sectigo, GlobalSign (~$100-400/year)
- **Requirements**: Verified identity/company information
- **Benefits**: Immediate trust, no SmartScreen warnings after building reputation

### Option 2: Self-Signed Certificate (Testing/Internal Use Only)
- **Free** but will still trigger SmartScreen warnings
- **Use case**: Testing the signing process, internal distribution only
- Users will see "Unknown Publisher" warnings

## Method 1: Sign with Commercial Certificate

### Step 1: Install Certificate
1. Receive your certificate file (usually `.pfx` or `.p12`)
2. Double-click to install in Windows Certificate Store
3. Follow wizard, choose "Local Machine" or "Current User"
4. Set a strong password when prompted

### Step 2: Sign the EXE

Using `signtool.exe` (included with Windows SDK):

```powershell
# Find signtool.exe location
$signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"

# Sign with certificate from store
& $signtool sign /a /n "Your Certificate Name" /t http://timestamp.digicert.com /fd SHA256 "Minecraft Font Tool for VSC.exe"

# Or sign with PFX file
& $signtool sign /f "path\to\certificate.pfx" /p "password" /t http://timestamp.digicert.com /fd SHA256 "Minecraft Font Tool for VSC.exe"
```

### Step 3: Verify Signature

```powershell
& $signtool verify /pa "Minecraft Font Tool for VSC.exe"
```

## Method 2: Self-Signed Certificate (Testing Only)

### Step 1: Create Self-Signed Certificate

```powershell
# Create certificate (run as Administrator)
$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject "CN=MinecraftFontTool" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(2)

# Export certificate
$password = ConvertTo-SecureString -String "YourPassword123" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath ".\MinecraftFontTool.pfx" -Password $password
```

### Step 2: Sign the EXE

```powershell
$signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"
& $signtool sign /f "MinecraftFontTool.pfx" /p "YourPassword123" /fd SHA256 "Minecraft Font Tool for VSC.exe"
```

**Note**: Self-signed executables will still show SmartScreen warnings to end users.

## Automated Signing in Build Script

To automate signing, add to `build-minecraft-font-installer.ps1` after Launch4j step:

```powershell
# After Launch4j completes...

# Optional: Sign the EXE
$signExe = $false  # Set to $true to enable signing
if ($signExe) {
    Write-Host 'Signing executable...'
    $signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"
    
    if (Test-Path $signtool) {
        # Method 1: Sign with certificate from store (recommended)
        & $signtool sign /a /n "Your Certificate Name" /t http://timestamp.digicert.com /fd SHA256 $exePath
        
        # Method 2: Sign with PFX file
        # $pfxPath = Join-Path $projectRoot 'certificate.pfx'
        # $pfxPassword = 'YourPassword'
        # & $signtool sign /f $pfxPath /p $pfxPassword /t http://timestamp.digicert.com /fd SHA256 $exePath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host 'Executable signed successfully!' -ForegroundColor Green
        } else {
            Write-Warning 'Signing failed. Continuing with unsigned executable.'
        }
    } else {
        Write-Warning "signtool.exe not found. Install Windows SDK to enable signing."
    }
}
```

## Timestamping

Always use a timestamp server (`/t` parameter):
- **DigiCert**: `http://timestamp.digicert.com`
- **Sectigo**: `http://timestamp.sectigo.com`
- **GlobalSign**: `http://timestamp.globalsign.com/tsa/r6advanced1`

Timestamps ensure signature remains valid even after certificate expires.

## Verifying Your Signature

After signing, verify:

1. **Command line**:
   ```powershell
   signtool verify /pa "Minecraft Font Tool for VSC.exe"
   ```

2. **Windows Explorer**:
   - Right-click EXE → Properties
   - Check "Digital Signatures" tab
   - Should show your certificate details

3. **Test SmartScreen**:
   - Download signed EXE from internet (email to yourself or cloud storage)
   - Run it on a different PC
   - SmartScreen should show your publisher name instead of "Unknown Publisher"

## Costs & Recommendations

| Certificate Type | Annual Cost | SmartScreen Trust | Use Case |
|------------------|-------------|-------------------|----------|
| Self-Signed | Free | ❌ No | Testing only |
| Standard Code Signing | $100-$400 | ⚠️ After reputation | Individual/Small teams |
| EV Code Signing | $300-$700 | ✅ Immediate | Commercial/High-volume |

**Recommendation for distribution**: Get an EV (Extended Validation) certificate for immediate SmartScreen trust.

## Resources

- [Microsoft Code Signing Guide](https://docs.microsoft.com/en-us/windows/win32/seccrypto/using-signtool-to-sign-a-file)
- [Windows SDK Download](https://developer.microsoft.com/windows/downloads/windows-sdk/)
- Certificate Authorities:
  - [DigiCert Code Signing](https://www.digicert.com/signing/code-signing-certificates)
  - [Sectigo Code Signing](https://sectigo.com/ssl-certificates-tls/code-signing)
  - [GlobalSign Code Signing](https://www.globalsign.com/en/code-signing-certificate)

## Troubleshooting

**"Certificate not found"**:
- Run `certmgr.msc` and verify certificate is installed in Personal store
- Check certificate has Code Signing purpose
- Use exact certificate subject name with `/n` parameter

**"Timestamp server error"**:
- Try alternative timestamp servers
- Check internet connection
- Retry after a few seconds

**"Access denied"**:
- Run PowerShell/Command Prompt as Administrator
- Check file is not locked by another process
- Ensure you have write permissions
