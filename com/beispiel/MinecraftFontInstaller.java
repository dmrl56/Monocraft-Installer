package com.beispiel;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class MinecraftFontInstaller {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Minecraft Font Installer");
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

        addButton.addActionListener(e -> runScript("minecraft_font-VSC.ps1"));
        removeButton.addActionListener(e -> runScript("rm-minecraft_font-VSC.ps1"));

        panel.add(addButton);
        panel.add(Box.createRigidArea(new Dimension(30, 0)));
        panel.add(removeButton);

        frame.add(panel, BorderLayout.CENTER);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    private static void runScript(String scriptName) {
        // Use absolute paths for the scripts
        String basePath = System.getProperty("user.dir");
        String scriptPath;
        if (scriptName.equals("minecraft_font-VSC.ps1")) {
            scriptPath = basePath + "\\minecraft_font-VSC.ps1";
        } else if (scriptName.equals("rm-minecraft_font-VSC.ps1")) {
            scriptPath = basePath + "\\rm-minecraft_font-VSC.ps1";
        } else {
            scriptPath = basePath + "\\" + scriptName;
        }
        ProcessBuilder pb = new ProcessBuilder(
                "powershell.exe",
                "-ExecutionPolicy", "Bypass",
                "-File", scriptPath
        );
        pb.redirectErrorStream(true);
        try {
            Process process = pb.start();
            int exitCode = process.waitFor();
            if (exitCode != 0) {
                JOptionPane.showMessageDialog(null, "Script execution failed. Exit code: " + exitCode, "Error", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException | InterruptedException ex) {
            JOptionPane.showMessageDialog(null, "Error executing script: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
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