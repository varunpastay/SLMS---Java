package com.slms.servlet.admin;

import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.PasswordUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import com.slms.config.DBConfig;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/bulk-import")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class BulkStudentImportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        req.getRequestDispatcher("/views/admin/bulkImport.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;

        Part filePart = req.getPart("csvFile");
        if (filePart == null || filePart.getSize() == 0) {
            req.setAttribute("error", "Please upload a CSV file.");
            req.getRequestDispatcher("/views/admin/bulkImport.jsp").forward(req, resp); return;
        }

        List<String> results = new ArrayList<>();
        int success = 0, skipped = 0, failed = 0;

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(filePart.getInputStream(), StandardCharsets.UTF_8))) {

            UserDAOImpl userDAO = new UserDAOImpl();
            String line; boolean first = true;
            while ((line = reader.readLine()) != null) {
                line = line.replace("﻿", "").trim();
                if (line.isEmpty()) continue;
                if (first) { first = false; continue; } // skip header

                String[] parts = line.split(",", -1);
                if (parts.length < 3) { results.add("❌ Bad line: " + line); failed++; continue; }
                String name = parts[0].trim(); String email = parts[1].trim(); String username = parts.length > 2 ? parts[2].trim() : "";
                String password = parts.length > 3 ? parts[3].trim() : "Student@123";

                if (name.isEmpty() || email.isEmpty()) { results.add("❌ Missing name/email: " + line); failed++; continue; }
                if (username.isEmpty()) username = email.split("@")[0];

                // Check duplicate
                try (Connection dupCon = DBConfig.getConnection();
                     PreparedStatement ps = dupCon.prepareStatement("SELECT id FROM users WHERE email=? OR username=?")) {
                    ps.setString(1, email); ps.setString(2, username);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) { results.add("⚠️ Skipped (exists): " + email); skipped++; continue; }
                }

                try {
                    String[] nameParts = name.split(" ", 2);
                    UserDTO u = new UserDTO();
                    u.setFirstName(nameParts[0]);
                    u.setLastName(nameParts.length > 1 ? nameParts[1] : "");
                    u.setEmail(email); u.setUsername(username);
                    u.setPasswordHash(PasswordUtil.hash(password)); u.setRole("STUDENT");
                    userDAO.save(u);
                    results.add("✅ Created: " + name + " (" + email + ")"); success++;
                } catch (Exception e) { results.add("❌ Error: " + email + " – " + e.getMessage()); failed++; }
            }
        } catch (Exception e) { throw new ServletException(e); }

        req.setAttribute("results", results);
        req.setAttribute("success", success); req.setAttribute("skipped", skipped); req.setAttribute("failed", failed);
        req.getRequestDispatcher("/views/admin/bulkImport.jsp").forward(req, resp);
    }
}
