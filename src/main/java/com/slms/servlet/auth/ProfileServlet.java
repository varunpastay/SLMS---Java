package com.slms.servlet.auth;

import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.FileUploadUtil;
import com.slms.util.PasswordUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

@WebServlet("/profile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class ProfileServlet extends HttpServlet {

    private UserDAO userDAO;
    private String uploadDir;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties p = new Properties();
            p.load(in);
            uploadDir = p.getProperty("upload.dir", "C:/slms_uploads");
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        req.getRequestDispatcher("/views/auth/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO loggedUser = SessionUtil.getLoggedUser(req);
        if (loggedUser == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");

        try {
            if ("changePassword".equals(action)) {
                String current  = req.getParameter("currentPassword");
                String newPass  = req.getParameter("newPassword");
                String confirm  = req.getParameter("confirmPassword");
                if (!PasswordUtil.verify(current, loggedUser.getPasswordHash())) {
                    req.setAttribute("error", "Current password is incorrect.");
                } else if (!newPass.equals(confirm)) {
                    req.setAttribute("error", "New passwords do not match.");
                } else {
                    userDAO.updatePassword(loggedUser.getId(), PasswordUtil.hash(newPass));
                    loggedUser.setPasswordHash(PasswordUtil.hash(newPass));
                    req.setAttribute("success", "Password changed successfully.");
                }
            } else {
                String firstName = req.getParameter("firstName");
                String lastName  = req.getParameter("lastName");
                String bio       = req.getParameter("bio");

                String picPath = FileUploadUtil.saveFile(req, "profilePic", "profiles", uploadDir);

                loggedUser.setFirstName(firstName);
                loggedUser.setLastName(lastName);
                loggedUser.setBio(bio);
                if (picPath != null) loggedUser.setProfilePic(picPath);

                userDAO.update(loggedUser);
                SessionUtil.setLoggedUser(req, loggedUser);
                req.setAttribute("success", "Profile updated successfully.");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Update failed: " + e.getMessage());
        }

        req.getRequestDispatcher("/views/auth/profile.jsp").forward(req, resp);
    }
}
