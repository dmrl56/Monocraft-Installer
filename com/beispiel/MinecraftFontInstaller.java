package com.beispiel;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MinecraftFontInstaller {
    private static final String FONT_FAMILY = "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace";
    private static final String TERMINAL_FONT = "Monocraft Nerd Font";

    public static void main(String[] args) {
        // Set locale to English to ensure button labels are in English
        Locale.setDefault(Locale.ENGLISH);
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Minecraft Font Tool");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(600, 280);
        frame.setLayout(new BorderLayout());
        frame.getContentPane().setBackground(new Color(34, 40, 49));

        // Title label
        JLabel titleLabel = new JLabel("Minecraft Font for VS Code", SwingConstants.CENTER);
        titleLabel.setFont(new Font("Segoe UI", Font.BOLD, 22));
        titleLabel.setForeground(new Color(255, 211, 105));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(20, 10, 10, 10));
        frame.add(titleLabel, BorderLayout.NORTH);

        // Main panel with vertical layout
        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.Y_AXIS));
        mainPanel.setBackground(new Color(34, 40, 49));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(10, 30, 20, 30));

        // Font installation panel (top)
        JPanel fontPanel = new JPanel();
        fontPanel.setLayout(new BoxLayout(fontPanel, BoxLayout.X_AXIS));
        fontPanel.setBackground(new Color(34, 40, 49));
        fontPanel.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton installButton = new JButton("Install Fonts");
        JButton uninstallButton = new JButton("Uninstall Fonts");

        // Settings panel (bottom)
        JPanel settingsPanel = new JPanel();
        settingsPanel.setLayout(new BoxLayout(settingsPanel, BoxLayout.X_AXIS));
        settingsPanel.setBackground(new Color(34, 40, 49));
        settingsPanel.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton addButton = new JButton("Add Minecraft Font");
        JButton removeButton = new JButton("Remove Minecraft Font");

        // Style all buttons consistently
        Font buttonFont = new Font("Segoe UI", Font.PLAIN, 16);
        
        // Install/Uninstall buttons - blue/orange theme
        installButton.setFont(buttonFont);
        installButton.setBackground(new Color(72, 149, 239));
        installButton.setForeground(Color.WHITE);
        installButton.setFocusPainted(false);
        installButton.setPreferredSize(new Dimension(200, 50));
        installButton.setMaximumSize(new Dimension(200, 50));

        uninstallButton.setFont(buttonFont);
        uninstallButton.setBackground(new Color(255, 159, 64));
        uninstallButton.setForeground(Color.WHITE);
        uninstallButton.setFocusPainted(false);
        uninstallButton.setPreferredSize(new Dimension(200, 50));
        uninstallButton.setMaximumSize(new Dimension(200, 50));

        // Add/Remove buttons - green/red theme
        addButton.setFont(buttonFont);
        addButton.setBackground(new Color(57, 255, 20));
        addButton.setForeground(Color.BLACK);
        addButton.setFocusPainted(false);
        addButton.setPreferredSize(new Dimension(200, 50));
        addButton.setMaximumSize(new Dimension(200, 50));

        removeButton.setFont(buttonFont);
        removeButton.setBackground(new Color(255, 71, 87));
        removeButton.setForeground(Color.WHITE);
        removeButton.setFocusPainted(false);
        removeButton.setPreferredSize(new Dimension(200, 50));
        removeButton.setMaximumSize(new Dimension(200, 50));

        // Add action listeners
        installButton.addActionListener(e -> showInstallMenu(installButton));
        uninstallButton.addActionListener(e -> uninstallFontsWithWarning());
        addButton.addActionListener(e -> modifySettings(true));
        removeButton.addActionListener(e -> modifySettings(false));

        // Assemble font panel
        fontPanel.add(Box.createHorizontalGlue());
        fontPanel.add(installButton);
        fontPanel.add(Box.createRigidArea(new Dimension(20, 0)));
        fontPanel.add(uninstallButton);
        fontPanel.add(Box.createHorizontalGlue());

        // Assemble settings panel
        settingsPanel.add(Box.createHorizontalGlue());
        settingsPanel.add(addButton);
        settingsPanel.add(Box.createRigidArea(new Dimension(20, 0)));
        settingsPanel.add(removeButton);
        settingsPanel.add(Box.createHorizontalGlue());

        // Add panels to main panel
        mainPanel.add(fontPanel);
        mainPanel.add(Box.createRigidArea(new Dimension(0, 15)));
        mainPanel.add(settingsPanel);

        frame.add(mainPanel, BorderLayout.CENTER);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    private static void showInstallMenu(JButton installButton) {
        JPopupMenu menu = new JPopupMenu();
        
        JMenuItem installOnlyItem = new JMenuItem("Install Fonts Only");
        installOnlyItem.addActionListener(e -> showProgressDialog(() -> installFonts(false)));
        
        JMenuItem installAndAddItem = new JMenuItem("Install Fonts & Add to VS Code");
        installAndAddItem.addActionListener(e -> showProgressDialog(() -> installFonts(true)));
        
        menu.add(installOnlyItem);
        menu.add(installAndAddItem);
        
        // Show menu below the button
        menu.show(installButton, 0, installButton.getHeight());
    }

    private static void uninstallFontsWithWarning() {
        int choice = JOptionPane.showConfirmDialog(null, 
            "Please close Visual Studio Code before uninstalling fonts.\n\n" +
            "This will:\n" +
            "1. Remove Minecraft font settings from VS Code\n" +
            "2. Uninstall font files from Windows\n\n" +
            "Have you closed VS Code?", 
            "Close VS Code First", 
            JOptionPane.YES_NO_OPTION, 
            JOptionPane.WARNING_MESSAGE);
        
        if (choice == JOptionPane.YES_OPTION) {
            showProgressDialog(() -> {
                // First remove from VS Code settings silently
                modifySettings(false, false);
                // Then uninstall fonts
                uninstallFonts();
            });
        }
    }

    private static void modifySettings(boolean add) {
        modifySettings(add, true);
    }

    private static void modifySettings(boolean add, boolean showMessage) {
        try {
            String userHome = System.getProperty("user.home");
            Path settingsPath = Paths.get(userHome, "AppData", "Roaming", "Code", "User", "settings.json");

            if (!Files.exists(settingsPath)) {
                if (showMessage) {
                    JOptionPane.showMessageDialog(null, "VS Code settings.json not found at:\n" + settingsPath, "Error", JOptionPane.ERROR_MESSAGE);
                }
                return;
            }

            // Read settings.json
            String content = Files.readString(settingsPath, StandardCharsets.UTF_8);

            if (add) {
                // Add or update Minecraft font settings
                content = addOrUpdateProperty(content, "editor.fontFamily", FONT_FAMILY);
                content = addOrUpdateProperty(content, "editor.fontLigatures", "true");
                content = addOrUpdateProperty(content, "terminal.integrated.fontFamily", TERMINAL_FONT);
            } else {
                // Remove Minecraft font settings
                content = removeProperty(content, "editor.fontFamily");
                content = removeProperty(content, "editor.fontLigatures");
                content = removeProperty(content, "terminal.integrated.fontFamily");
            }

            // Write back to file
            Files.writeString(settingsPath, content, StandardCharsets.UTF_8);

        } catch (IOException ex) {
            if (showMessage) {
                JOptionPane.showMessageDialog(null, "Error modifying settings: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private static String addOrUpdateProperty(String json, String key, String value) {
        // Operate on lines to preserve user formatting as much as possible
        String[] rawLines = json.split("\n", -1);
        List<String> lines = new ArrayList<>();
        for (String l : rawLines) lines.add(l);

        String newProperty;
        if ("true".equals(value) || "false".equals(value)) {
            newProperty = "    \"" + key + "\": " + value;
        } else {
            newProperty = "    \"" + key + "\": \"" + value + "\"";
        }

        // 1) Replace existing property if present
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line.contains("\"" + key + "\"")) {
                boolean hasComma = line.trim().endsWith(",");
                lines.set(i, newProperty + (hasComma ? "," : ""));
                return String.join("\n", lines);
            }
        }

        // 2) Insert before the last closing brace
        int insertIndex = -1;
        for (int i = lines.size() - 1; i >= 0; i--) {
            if (lines.get(i).trim().equals("}")) {
                insertIndex = i;
                break;
            }
        }

        if (insertIndex == -1) {
            // No closing brace found - append at end
            lines.add(newProperty);
            return String.join("\n", lines);
        }

        // Make sure the previous meaningful line ends with a comma if it's a property
        int prev = insertIndex - 1;
        while (prev >= 0 && lines.get(prev).trim().isEmpty()) prev--;
        if (prev >= 0) {
            String prevLine = lines.get(prev);
            String t = prevLine.trim();
            if (!t.equals("{") && !t.endsWith(",")) {
                lines.set(prev, prevLine + ",");
            }
        }

        lines.add(insertIndex, newProperty);
        return String.join("\n", lines);
    }

    private static String removeProperty(String json, String key) {
        String[] rawLines = json.split("\n", -1);
        List<String> lines = new ArrayList<>();
        for (String l : rawLines) lines.add(l);

        boolean removed = false;
        for (int i = 0; i < lines.size(); ) {
            String line = lines.get(i);
            if (line.contains("\"" + key + "\"")) {
                lines.remove(i);
                removed = true;
            } else {
                i++;
            }
        }

        if (!removed) return json;

        // If we removed a property, ensure we don't leave a dangling comma before a closing brace
        for (int i = 0; i < lines.size(); i++) {
            if (lines.get(i).trim().equals("}")) {
                int prev = i - 1;
                while (prev >= 0 && lines.get(prev).trim().isEmpty()) prev--;
                if (prev >= 0) {
                    String prevLine = lines.get(prev);
                    if (prevLine.trim().endsWith(",")) {
                        // Check if there is another property above prev; if none, remove the comma
                        boolean hasAnother = false;
                        for (int j = prev - 1; j >= 0; j--) {
                            String t = lines.get(j).trim();
                            if (t.isEmpty()) continue;
                            if (t.equals("{")) break;
                            hasAnother = true;
                            break;
                        }
                        if (!hasAnother) {
                            lines.set(prev, prevLine.replaceFirst(",\\s*$", ""));
                        }
                    }
                }
            }
        }

        return String.join("\n", lines);
    }

    // Installs the Monocraft fonts for the current user (no admin required)
    private static void installFonts(boolean alsoAddToVSCode) {
        try {
            // First check if fonts are already installed correctly
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

            // Prefer bundled resources if available; otherwise fall back to Monocraft-font folder next to executable
            List<Path> extracted = extractBundledFonts();
            Path ttc = null, ttf = null;
            for (Path p : extracted) {
                String n = p.getFileName().toString().toLowerCase();
                if (n.endsWith(".ttc")) ttc = p;
                if (n.endsWith(".ttf")) ttf = p;
            }

            if (ttc == null || ttf == null) {
                // fallback to external folder
                String projectDir = Paths.get("").toAbsolutePath().toString();
                Path srcDir = Paths.get(projectDir, "Monocraft-font");
                Path altTtc = srcDir.resolve("Monocraft-nerd-fonts-patched.ttc");
                Path altTtf = srcDir.resolve("Monocraft-ttf-otf").resolve("other-formats").resolve("Monocraft.ttf");
                if (Files.exists(altTtc)) ttc = altTtc;
                if (Files.exists(altTtf)) ttf = altTtf;
            }

            if ((ttc == null || !Files.exists(ttc)) && (ttf == null || !Files.exists(ttf))) {
                JOptionPane.showMessageDialog(null, "Font files not found. Include Monocraft-font folder next to the app or bundle fonts into the jar.", "Fonts not found", JOptionPane.WARNING_MESSAGE);
                return;
            }

            String localAppData = System.getenv("LOCALAPPDATA");
            if (localAppData == null || localAppData.isEmpty()) localAppData = System.getProperty("user.home") + "\\AppData\\Local";
            Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");
            if (!Files.exists(fontsDest)) Files.createDirectories(fontsDest);

            if (ttc != null && Files.exists(ttc)) {
                Path destTtc = fontsDest.resolve(ttc.getFileName());
                copyFile(ttc, destTtc);
                runCommand(new String[]{"reg", "add", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", "/v", "Monocraft Nerd Font (TrueType)", "/t", "REG_SZ", "/d", destTtc.getFileName().toString(), "/f"}, true);
            }

            if (ttf != null && Files.exists(ttf)) {
                Path destTtf = fontsDest.resolve(ttf.getFileName());
                copyFile(ttf, destTtf);
                runCommand(new String[]{"reg", "add", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", "/v", "Monocraft", "/t", "REG_SZ", "/d", destTtf.getFileName().toString(), "/f"}, true);
            }

            // Verify
            boolean ok = verifyInstallation();
            if (ok) {
                if (alsoAddToVSCode) {
                    // Also add to VS Code settings
                    modifySettings(true, false);
                    JOptionPane.showMessageDialog(null, "Fonts installed and added to VS Code successfully!\n\nRestart VS Code to use the Minecraft font.", "Success", JOptionPane.INFORMATION_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(null, "Fonts installed successfully for the current user.\n\nUse 'Add Minecraft Font' button to configure VS Code.", "Success", JOptionPane.INFORMATION_MESSAGE);
                }
            } else {
                JOptionPane.showMessageDialog(null, "Fonts copied but verification failed. You may need to sign out/in.", "Partial Success", JOptionPane.WARNING_MESSAGE);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(null, "Error installing fonts:\n" + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private static void uninstallFonts() {
        try {
            String localAppData = System.getenv("LOCALAPPDATA");
            if (localAppData == null || localAppData.isEmpty()) localAppData = System.getProperty("user.home") + "\\AppData\\Local";
            Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");

            // Delete known files
            Path ttc = fontsDest.resolve("Monocraft-nerd-fonts-patched.ttc");
            Path ttf = fontsDest.resolve("Monocraft.ttf");
            if (Files.exists(ttc)) Files.delete(ttc);
            if (Files.exists(ttf)) Files.delete(ttf);

            // Remove registry entries
            runCommand(new String[]{"reg", "delete", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", "/v", "Monocraft Nerd Font (TrueType)", "/f"}, true);
            runCommand(new String[]{"reg", "delete", "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts", "/v", "Monocraft", "/f"}, true);

            JOptionPane.showMessageDialog(null, "Fonts uninstalled for the current user.", "Uninstalled", JOptionPane.INFORMATION_MESSAGE);
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(null, "Error uninstalling fonts: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private static List<Path> extractBundledFonts() throws IOException {
        List<Path> results = new ArrayList<>();
        // Try to read resources from classpath
        // The fonts would be bundled at root: /Monocraft-font/...
        String[] candidates = new String[]{
            "/Monocraft-font/Monocraft-nerd-fonts-patched.ttc", 
            "/Monocraft-font/Monocraft-ttf-otf/other-formats/Monocraft.ttf"
        };
        
        // Use system temp dir instead of creating our own
        Path tmpDir = Paths.get(System.getProperty("java.io.tmpdir"), "monocraft-fonts-" + System.currentTimeMillis());
        if (!Files.exists(tmpDir)) {
            Files.createDirectories(tmpDir);
        }
        
        for (String c : candidates) {
            java.io.InputStream is = null;
            try {
                is = MinecraftFontInstaller.class.getResourceAsStream(c);
                if (is == null) continue;
                
                Path out = tmpDir.resolve(Paths.get(c).getFileName().toString());
                Files.copy(is, out, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                results.add(out);
            } catch (Exception ignored) {
                // If extraction fails, continue with next candidate
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException ignored) {}
                }
            }
        }
        return results;
    }

    private static boolean verifyInstallation() throws IOException {
        String localAppData = System.getenv("LOCALAPPDATA");
        if (localAppData == null || localAppData.isEmpty()) localAppData = System.getProperty("user.home") + "\\AppData\\Local";
        Path fontsDest = Paths.get(localAppData, "Microsoft", "Windows", "Fonts");
        boolean a = Files.exists(fontsDest.resolve("Monocraft-nerd-fonts-patched.ttc"));
        boolean b = Files.exists(fontsDest.resolve("Monocraft.ttf"));
        return a || b;
    }

    private static void showProgressDialog(Runnable action) {
        final JDialog dialog = new JDialog((Frame) null, "Working...", true);
        JLabel label = new JLabel("Please wait...", SwingConstants.CENTER);
        dialog.getContentPane().add(label);
        dialog.setSize(300, 100);
        dialog.setLocationRelativeTo(null);

        Thread t = new Thread(() -> {
            try {
                action.run();
            } finally {
                SwingUtilities.invokeLater(dialog::dispose);
            }
        });
        t.start();
        dialog.setVisible(true);
    }

    private static void copyFile(Path src, Path dest) throws IOException {
        // Try to delete the destination first if it exists and is in use
        if (Files.exists(dest)) {
            try {
                Files.delete(dest);
            } catch (IOException e) {
                // If delete fails, try to wait a moment and retry
                try {
                    Thread.sleep(100);
                    Files.delete(dest);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                } catch (IOException e2) {
                    throw new IOException("Cannot overwrite " + dest.getFileName() + 
                        " - the file may be in use. Please close any applications using this font and try again.", e2);
                }
            }
        }
        // Now copy with replace option
        Files.copy(src, dest, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
    }

    private static void runCommand(String[] cmd, boolean wait) throws IOException {
        ProcessBuilder pb = new ProcessBuilder(cmd);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        if (wait) {
            try (java.io.InputStream is = p.getInputStream()) {
                is.transferTo(System.out);
            } catch (IOException ignored) {}
            try {
                p.waitFor();
            } catch (InterruptedException ignored) {
                Thread.currentThread().interrupt();
            }
        }
    }
}

/*
 * How to create a .exe from .java
 * 1. Compile the Java code to bytecode using javac:
 *    javac com\beispiel\MinecraftFontInstaller.java
 * 2. Create a JAR file from the compiled classes:
 *    jar cfm MinecraftFontInstaller.jar manifest.txt -C . com
 * 3. Use a tool like Launch4j or JSmooth to wrap the JAR file in a Windows executable.
 * 4. Configure the wrapper tool with the JAR file and any required JVM options.
 * 5. Build the executable and distribute it.
 */