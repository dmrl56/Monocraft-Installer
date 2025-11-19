package com.example;

import java.io.IOException;

/**
 * System utility methods for running external commands.
 */
public class SystemUtils {
    
    /**
     * Executes a system command.
     * 
     * @param cmd Command and arguments to execute
     * @param wait If true, waits for command to complete
     * @throws IOException If command execution fails
     */
    public static void runCommand(String[] cmd, boolean wait) throws IOException {
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
