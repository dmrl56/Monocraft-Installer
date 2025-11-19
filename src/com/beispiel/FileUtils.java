package com.beispiel;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * File utility methods.
 */
public class FileUtils {
    
    /**
     * Copies a file from source to destination with retry logic for files in use.
     * 
     * @param src Source file path
     * @param dest Destination file path
     * @throws IOException If copy fails
     */
    public static void copyFile(Path src, Path dest) throws IOException {
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
}
