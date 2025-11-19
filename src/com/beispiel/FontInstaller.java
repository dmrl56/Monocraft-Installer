package com.beispiel;

import javax.swing.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles Monocraft font installation and uninstallation for the current user.
 * No administrator privileges required.
 */
public class FontInstaller {
    private static final String FONT_NERD_NAME = "Monocraft Nerd Font (TrueType)";
    private static final String FONT_REGULAR_NAME = "Monocraft";
    
    /**
     * Installs the Monocraft fonts for the current user.
     * 
     * @param alsoAddToVSCode If true, also configures VS Code settings
     * @throws IOException If font installation fails
     */
    public static void installFonts(boolean alsoAddToVSCode) throws IOException {
        // Check if already installed
        if (verifyInstallation()) {
            int choice = JOptionPane.showConfirmDialog(null, 
                "Fonts are already installed correctly.\nDo you want to reinstall them?", 
                "Already Installed", 
                JOptionPane.YES_NO_OPTION, 
                JOptionPane.INFORMATION_MESSAGE);
            if (choice != JOptionPane.YES_OPTION) {
                return;
            }
        }

        // Extract or locate font files
        List<Path> extracted = extractBundledFonts();
        Path ttc = null, ttf = null;
        for (Path p : extracted) {
            String n = p.getFileName().toString().toLowerCase();
            if (n.endsWith(".ttc")) ttc = p;
            if (n.endsWith(".ttf")) ttf = p;
        }

        // Fallback to external folder if not bundled
        if (ttc == null || ttf == null) {
            String projectDir = Paths.get("").toAbsolutePath().toString();
            Path srcDir = Paths.get(projectDir, "resources", "fonts", "Monocraft-font");
            Path altTtc = srcDir.resolve("Monocraft-nerd-fonts-patched.ttc");
            Path altTtf = srcDir.resolve("Monocraft-ttf-otf").resolve("other-formats").resolve("Monocraft.ttf");
            if (Files.exists(altTtc)) ttc = altTtc;
            if (Files.exists(altTtf)) ttf = altTtf;
        }

        if ((ttc == null || !Files.exists(ttc)) && (ttf == null || !Files.exists(ttf))) {
            throw new IOException("Font files not found. Include Monocraft-font folder or bundle fonts into the jar.");
        }

        // Get user fonts directory
        String localAppData = System.getenv("LOCALAPPDATA");
        if (localAppData == null || localAppData.isEmpty()) {
            localAppData = System.getProperty("user.home") + "\\AppData\\Local";
        }
        Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");
        if (!Files.exists(fontsDest)) {
            Files.createDirectories(fontsDest);
        }

        // Install TTC font
        if (ttc != null && Files.exists(ttc)) {
            Path destTtc = fontsDest.resolve(ttc.getFileName());
            FileUtils.copyFile(ttc, destTtc);
            SystemUtils.runCommand(new String[]{
                "reg", "add", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", 
                "/v", FONT_NERD_NAME, "/t", "REG_SZ", "/d", destTtc.getFileName().toString(), "/f"
            }, true);
        }

        // Install TTF font
        if (ttf != null && Files.exists(ttf)) {
            Path destTtf = fontsDest.resolve(ttf.getFileName());
            FileUtils.copyFile(ttf, destTtf);
            SystemUtils.runCommand(new String[]{
                "reg", "add", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", 
                "/v", FONT_REGULAR_NAME, "/t", "REG_SZ", "/d", destTtf.getFileName().toString(), "/f"
            }, true);
        }

        // Verify installation
        boolean success = verifyInstallation();
        if (success) {
            if (alsoAddToVSCode) {
                SettingsManager.modifySettings(true, false);
                JOptionPane.showMessageDialog(null, 
                    "Fonts installed and added to VS Code successfully!", 
                    "Success", JOptionPane.INFORMATION_MESSAGE);
            } else {
                JOptionPane.showMessageDialog(null, 
                    "Fonts installed successfully for the current user.\n\nUse 'Add Monocraft Font' button to configure VS Code.", 
                    "Success", JOptionPane.INFORMATION_MESSAGE);
            }
        } else {
            JOptionPane.showMessageDialog(null, 
                "Fonts copied but verification failed. You may need to sign out/in.", 
                "Partial Success", JOptionPane.WARNING_MESSAGE);
        }
    }

    /**
     * Uninstalls the Monocraft fonts from the current user's system.
     * 
     * @throws IOException If font uninstallation fails
     */
    public static void uninstallFonts() throws IOException {
        String localAppData = System.getenv("LOCALAPPDATA");
        if (localAppData == null || localAppData.isEmpty()) {
            localAppData = System.getProperty("user.home") + "\\AppData\\Local";
        }
        Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");

        // Delete font files
        Path ttc = fontsDest.resolve("Monocraft-nerd-fonts-patched.ttc");
        Path ttf = fontsDest.resolve("Monocraft.ttf");
        if (Files.exists(ttc)) Files.delete(ttc);
        if (Files.exists(ttf)) Files.delete(ttf);

        // Remove registry entries
        SystemUtils.runCommand(new String[]{
            "reg", "delete", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", 
            "/v", FONT_NERD_NAME, "/f"
        }, true);
        SystemUtils.runCommand(new String[]{
            "reg", "delete", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", 
            "/v", FONT_REGULAR_NAME, "/f"
        }, true);

        JOptionPane.showMessageDialog(null, 
            "Fonts uninstalled for the current user.", 
            "Uninstalled", JOptionPane.INFORMATION_MESSAGE);
    }

    /**
     * Extracts bundled font files from JAR resources to a temp directory.
     * 
     * @return List of extracted font file paths
     */
    private static List<Path> extractBundledFonts() throws IOException {
        List<Path> results = new ArrayList<>();
        String[] candidates = new String[]{
            "/Monocraft-font/Monocraft-nerd-fonts-patched.ttc", 
            "/Monocraft-font/Monocraft-ttf-otf/other-formats/Monocraft.ttf"
        };
        
        Path tmpDir = Paths.get(System.getProperty("java.io.tmpdir"), "monocraft-fonts-" + System.currentTimeMillis());
        if (!Files.exists(tmpDir)) {
            Files.createDirectories(tmpDir);
        }
        
        for (String c : candidates) {
            java.io.InputStream is = null;
            try {
                is = FontInstaller.class.getResourceAsStream(c);
                if (is == null) continue;
                
                Path out = tmpDir.resolve(Paths.get(c).getFileName().toString());
                Files.copy(is, out, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                results.add(out);
            } catch (Exception ignored) {
            } finally {
                if (is != null) {
                    try { is.close(); } catch (IOException ignored) {}
                }
            }
        }
        return results;
    }

    /**
     * Verifies if fonts are properly installed.
     * 
     * @return true if at least one font file is found
     */
    private static boolean verifyInstallation() throws IOException {
        String localAppData = System.getenv("LOCALAPPDATA");
        if (localAppData == null || localAppData.isEmpty()) {
            localAppData = System.getProperty("user.home") + "\\AppData\\Local";
        }
        Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");
        boolean hasTtc = Files.exists(fontsDest.resolve("Monocraft-nerd-fonts-patched.ttc"));
        boolean hasTtf = Files.exists(fontsDest.resolve("Monocraft.ttf"));
        return hasTtc || hasTtf;
    }
}
