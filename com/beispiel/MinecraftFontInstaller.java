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

public class MinecraftFontInstaller {
    private static final String FONT_FAMILY = "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace";
    private static final String TERMINAL_FONT = "Monocraft Nerd Font";

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Minecraft Font Tool");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(550, 220);
        frame.setLayout(new BorderLayout());
        frame.getContentPane().setBackground(new Color(34, 40, 49));

        // Title label
        JLabel titleLabel = new JLabel("Minecraft Font for VS Code", SwingConstants.CENTER);
        titleLabel.setFont(new Font("Segoe UI", Font.BOLD, 22));
        titleLabel.setForeground(new Color(255, 211, 105));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(20, 10, 10, 10));
        frame.add(titleLabel, BorderLayout.NORTH);

        // Button panel
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.X_AXIS));
        panel.setBackground(new Color(34, 40, 49));
        panel.setBorder(BorderFactory.createEmptyBorder(20, 30, 20, 30));

        JButton addButton = new JButton("Add Minecraft Font");
        JButton removeButton = new JButton("Remove Minecraft Font");

        Font buttonFont = new Font("Segoe UI", Font.PLAIN, 18);
        addButton.setFont(buttonFont);
        removeButton.setFont(buttonFont);
        addButton.setBackground(new Color(57, 255, 20));
        addButton.setForeground(Color.BLACK);
        removeButton.setBackground(new Color(255, 71, 87));
        removeButton.setForeground(Color.WHITE);
        addButton.setFocusPainted(false);
        removeButton.setFocusPainted(false);
        addButton.setPreferredSize(new Dimension(180, 50));
        removeButton.setPreferredSize(new Dimension(180, 50));

        addButton.addActionListener(e -> modifySettings(true));
        removeButton.addActionListener(e -> modifySettings(false));

        panel.add(addButton);
        panel.add(Box.createRigidArea(new Dimension(30, 0)));
        panel.add(removeButton);

        frame.add(panel, BorderLayout.CENTER);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    private static void modifySettings(boolean add) {
        try {
            String userHome = System.getProperty("user.home");
            Path settingsPath = Paths.get(userHome, "AppData", "Roaming", "Code", "User", "settings.json");

            if (!Files.exists(settingsPath)) {
                JOptionPane.showMessageDialog(null, "VS Code settings.json not found at:\n" + settingsPath, "Error", JOptionPane.ERROR_MESSAGE);
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
            JOptionPane.showMessageDialog(null, "Error modifying settings: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
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