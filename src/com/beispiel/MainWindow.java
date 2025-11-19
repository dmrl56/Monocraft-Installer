package com.beispiel;

import javax.swing.*;
import java.awt.*;

/**
 * Main application window with GUI components.
 */
public class MainWindow {
    
    /**
     * Creates and displays the main application window.
     */
    public static void createAndShowGUI() {
        JFrame frame = new JFrame("Monocraft Font Tool");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(760, 280);
        frame.setLayout(new BorderLayout());
        frame.getContentPane().setBackground(new Color(34, 40, 49));

        // Title label
        JLabel titleLabel = new JLabel("Monocraft Font for VS Code", SwingConstants.CENTER);
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
        JPanel fontPanel = createFontPanel();
        
        // Settings panel (bottom)
        JPanel settingsPanel = createSettingsPanel();

        // Add panels to main panel
        mainPanel.add(fontPanel);
        mainPanel.add(Box.createRigidArea(new Dimension(0, 15)));
        mainPanel.add(settingsPanel);

        frame.add(mainPanel, BorderLayout.CENTER);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    /**
     * Creates the font installation/uninstallation panel.
     */
    private static JPanel createFontPanel() {
        JPanel fontPanel = new JPanel();
        fontPanel.setLayout(new BoxLayout(fontPanel, BoxLayout.X_AXIS));
        fontPanel.setBackground(new Color(34, 40, 49));
        fontPanel.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton installButton = new JButton("Install Fonts");
        JButton uninstallButton = new JButton("Uninstall Fonts");

        // Style buttons
        Font buttonFont = new Font("Segoe UI", Font.PLAIN, 16);
        
        installButton.setFont(buttonFont);
        installButton.setBackground(new Color(72, 149, 239));
        installButton.setForeground(Color.WHITE);
        installButton.setFocusPainted(false);
        installButton.setPreferredSize(new Dimension(320, 50));
        installButton.setMaximumSize(new Dimension(320, 50));

        uninstallButton.setFont(buttonFont);
        uninstallButton.setBackground(new Color(255, 159, 64));
        uninstallButton.setForeground(Color.WHITE);
        uninstallButton.setFocusPainted(false);
        uninstallButton.setPreferredSize(new Dimension(320, 50));
        uninstallButton.setMaximumSize(new Dimension(320, 50));

        // Add action listeners
        installButton.addActionListener(e -> showInstallMenu(installButton));
        uninstallButton.addActionListener(e -> uninstallFontsWithWarning());

        // Assemble panel
        fontPanel.add(Box.createHorizontalGlue());
        fontPanel.add(installButton);
        fontPanel.add(Box.createRigidArea(new Dimension(20, 0)));
        fontPanel.add(uninstallButton);
        fontPanel.add(Box.createHorizontalGlue());

        return fontPanel;
    }

    /**
     * Creates the VS Code settings panel.
     */
    private static JPanel createSettingsPanel() {
        JPanel settingsPanel = new JPanel();
        settingsPanel.setLayout(new BoxLayout(settingsPanel, BoxLayout.X_AXIS));
        settingsPanel.setBackground(new Color(34, 40, 49));
        settingsPanel.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton addButton = new JButton("Add Monocraft Font");
        JButton removeButton = new JButton("Remove Monocraft Font");

        // Style buttons
        Font buttonFont = new Font("Segoe UI", Font.PLAIN, 16);
        
        addButton.setFont(buttonFont);
        addButton.setBackground(new Color(57, 255, 20));
        addButton.setForeground(Color.BLACK);
        addButton.setFocusPainted(false);
        addButton.setPreferredSize(new Dimension(320, 50));
        addButton.setMaximumSize(new Dimension(320, 50));

        removeButton.setFont(buttonFont);
        removeButton.setBackground(new Color(255, 71, 87));
        removeButton.setForeground(Color.WHITE);
        removeButton.setFocusPainted(false);
        removeButton.setPreferredSize(new Dimension(320, 50));
        removeButton.setMaximumSize(new Dimension(320, 50));

        // Add action listeners
        addButton.addActionListener(e -> SettingsManager.modifySettings(true));
        removeButton.addActionListener(e -> SettingsManager.modifySettings(false));

        // Assemble panel
        settingsPanel.add(Box.createHorizontalGlue());
        settingsPanel.add(addButton);
        settingsPanel.add(Box.createRigidArea(new Dimension(20, 0)));
        settingsPanel.add(removeButton);
        settingsPanel.add(Box.createHorizontalGlue());

        return settingsPanel;
    }

    /**
     * Shows the install menu with options.
     */
    private static void showInstallMenu(JButton installButton) {
        JPopupMenu menu = new JPopupMenu();
        
        JMenuItem installOnlyItem = new JMenuItem("Install Fonts Only");
        installOnlyItem.addActionListener(e -> showProgressDialog(() -> {
            try {
                FontInstaller.installFonts(false);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, 
                    "Error installing fonts: " + ex.getMessage(), 
                    "Error", JOptionPane.ERROR_MESSAGE);
            }
        }));
        
        JMenuItem installAndAddItem = new JMenuItem("Install Fonts & Add to VS Code");
        installAndAddItem.addActionListener(e -> showProgressDialog(() -> {
            try {
                FontInstaller.installFonts(true);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, 
                    "Error installing fonts: " + ex.getMessage(), 
                    "Error", JOptionPane.ERROR_MESSAGE);
            }
        }));
        
        menu.add(installOnlyItem);
        menu.add(installAndAddItem);
        
        menu.show(installButton, 0, installButton.getHeight());
    }

    /**
     * Shows uninstall confirmation and performs uninstallation.
     */
    private static void uninstallFontsWithWarning() {
        int choice = JOptionPane.showConfirmDialog(null, 
            "Please close Visual Studio Code before uninstalling fonts.\n\n" +
            "This will:\n" +
            "1. Remove Monocraft font settings from VS Code\n" +
            "2. Uninstall font files from Windows\n\n" +
            "Have you closed VS Code?", 
            "Close VS Code First", 
            JOptionPane.YES_NO_OPTION, 
            JOptionPane.WARNING_MESSAGE);
        
        if (choice == JOptionPane.YES_OPTION) {
            showProgressDialog(() -> {
                try {
                    // First remove from VS Code settings silently
                    SettingsManager.modifySettings(false, false);
                    // Then uninstall fonts
                    FontInstaller.uninstallFonts();
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, 
                        "Error uninstalling fonts: " + ex.getMessage(), 
                        "Error", JOptionPane.ERROR_MESSAGE);
                }
            });
        }
    }

    /**
     * Shows a progress dialog while executing an action.
     */
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
}
