package com.slms.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Uses the native Jakarta Servlet multipart API (request.getPart).
 * Servlets that call this must be annotated with @MultipartConfig.
 */
public class FileUploadUtil {

    public static String saveFile(HttpServletRequest req, String fieldName, String subDir, String uploadDir) throws Exception {
        Part part = req.getPart(fieldName);
        if (part == null || part.getSize() == 0) return null;

        String submittedName = extractFileName(part);
        if (submittedName == null || submittedName.isEmpty()) return null;

        String ext = "";
        int dot = submittedName.lastIndexOf('.');
        if (dot >= 0) ext = submittedName.substring(dot).toLowerCase();

        String savedName = UUID.randomUUID().toString() + ext;
        Path dir = Paths.get(uploadDir, subDir);
        Files.createDirectories(dir);
        Path dest = dir.resolve(savedName);

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
        }
        return subDir + "/" + savedName;
    }

    private static String extractFileName(Part part) {
        String disposition = part.getHeader("content-disposition");
        if (disposition == null) return null;
        for (String token : disposition.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                return Paths.get(name).getFileName().toString();
            }
        }
        return null;
    }

    public static boolean deleteFile(String relativePath, String uploadDir) {
        if (relativePath == null || relativePath.isBlank()) return false;
        File f = new File(uploadDir, relativePath);
        return f.exists() && f.delete();
    }

    private FileUploadUtil() {}
}
