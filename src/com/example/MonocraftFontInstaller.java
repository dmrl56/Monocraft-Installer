package com.example;

import javax.swing.SwingUtilities;
import java.util.Locale;

/**
 * Monocraft Font Tool for VS Code
 * 
 * A simple GUI application to install Monocraft fonts and configure 
 * Visual Studio Code font settings with one click.
 * 
 * Features:
 * - Install/uninstall Monocraft fonts for current user (no admin required)
 * - Add/remove Monocraft font configuration in VS Code settings
 * - Bundled fonts support for single-file distribution
 * 
 * @version 1.3.4
 */
public class MonocraftFontInstaller {
    
    public static void main(String[] args) {
        // Set locale to English to ensure button labels are in English
        Locale.setDefault(Locale.ENGLISH);
        
        // Launch the GUI on the Event Dispatch Thread
        SwingUtilities.invokeLater(() -> MainWindow.createAndShowGUI());
    }
}
