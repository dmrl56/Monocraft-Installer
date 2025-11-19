package com.beispiel;

import javax.swing.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Manages VS Code settings.json modifications for font configuration.
 */
public class SettingsManager {
    private static final String FONT_FAMILY = "Monocraft, 'Monocraft Nerd Font', Consolas, 'Courier New', monospace";
    private static final String TERMINAL_FONT = "Monocraft Nerd Font";
    
    /**
     * Modifies VS Code settings to add or remove Monocraft font configuration.
     * 
     * @param add If true, adds font settings; if false, removes them
     */
    public static void modifySettings(boolean add) {
        modifySettings(add, true);
    }
    
    /**
     * Modifies VS Code settings to add or remove Monocraft font configuration.
     * 
     * @param add If true, adds font settings; if false, removes them
     * @param showMessage If true, shows success/error dialogs
     */
    public static void modifySettings(boolean add, boolean showMessage) {
        try {
            String userHome = System.getProperty("user.home");
            Path settingsPath = Paths.get(userHome, "AppData", "Roaming", "Code", "User", "settings.json");

            if (!Files.exists(settingsPath)) {
                if (showMessage) {
                    JOptionPane.showMessageDialog(null, 
                        "VS Code settings.json not found at:\n" + settingsPath, 
                        "Error", JOptionPane.ERROR_MESSAGE);
                }
                return;
            }

            // Read settings.json
            String content = Files.readString(settingsPath, StandardCharsets.UTF_8);

            if (add) {
                // Add or update Monocraft font settings
                content = addOrUpdateProperty(content, "editor.fontFamily", FONT_FAMILY);
                content = addOrUpdateProperty(content, "editor.fontLigatures", "true");
                content = addOrUpdateProperty(content, "terminal.integrated.fontFamily", TERMINAL_FONT);
            } else {
                // Remove Monocraft font settings
                content = removeProperty(content, "editor.fontFamily");
                content = removeProperty(content, "editor.fontLigatures");
                content = removeProperty(content, "terminal.integrated.fontFamily");
            }

            // Write back to file
            Files.writeString(settingsPath, content, StandardCharsets.UTF_8);

        } catch (IOException ex) {
            if (showMessage) {
                JOptionPane.showMessageDialog(null, 
                    "Error modifying settings: " + ex.getMessage(), 
                    "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    /**
     * Adds or updates a property in the JSON settings.
     */
    private static String addOrUpdateProperty(String json, String key, String value) {
        // Operate on lines to preserve user formatting
        String[] rawLines = json.split("\n", -1);
        List<String> lines = new ArrayList<>();
        for (String l : rawLines) lines.add(l);

        String newProperty;
        if ("true".equals(value) || "false".equals(value)) {
            newProperty = "    \"" + key + "\": " + value;
        } else {
            newProperty = "    \"" + key + "\": \"" + value + "\"";
        }

        // Replace existing property if present
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line.contains("\"" + key + "\"")) {
                boolean hasComma = line.trim().endsWith(",");
                lines.set(i, newProperty + (hasComma ? "," : ""));
                return String.join("\n", lines);
            }
        }

        // Insert before the last closing brace
        int insertIndex = -1;
        for (int i = lines.size() - 1; i >= 0; i--) {
            if (lines.get(i).trim().equals("}")) {
                insertIndex = i;
                break;
            }
        }

        if (insertIndex == -1) {
            lines.add(newProperty);
            return String.join("\n", lines);
        }

        // Ensure previous line ends with comma
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

    /**
     * Removes a property from the JSON settings.
     */
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

        // Remove dangling comma before closing brace
        for (int i = 0; i < lines.size(); i++) {
            if (lines.get(i).trim().equals("}")) {
                int prev = i - 1;
                while (prev >= 0 && lines.get(prev).trim().isEmpty()) prev--;
                if (prev >= 0) {
                    String prevLine = lines.get(prev);
                    if (prevLine.trim().endsWith(",")) {
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
