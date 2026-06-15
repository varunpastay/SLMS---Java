package com.slms.servlet.auth;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Date;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;

    @Override
    public void init() {
        userDAO   = new UserDAOImpl();
        tokenDAO  = new PasswordResetTokenDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/auth/forgotPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        try {
            tokenDAO.deleteExpired();
            UserDTO user = userDAO.findByEmail(email);
            if (user != null && user.isActive()) {
                byte[] bytes = new byte[32];
                new SecureRandom().nextBytes(bytes);
                String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

                PasswordResetTokenDTO t = new PasswordResetTokenDTO();
                t.setUserId(user.getId());
                t.setToken(token);
                t.setExpiresAt(new Date(System.currentTimeMillis() + 30 * 60 * 1000)); // 30 min
                tokenDAO.save(t);

                String resetLink = req.getScheme() + "://" + req.getServerName() + ":" +
                                   req.getServerPort() + req.getContextPath() + "/reset-password?token=" + token;
                final String finalName = user.getFullName();
                final String finalEmail = user.getEmail();
                new Thread(() -> EmailUtil.sendPasswordReset(finalEmail, finalName, resetLink)).start();
            }
            // Always show same message to prevent email enumeration
            req.setAttribute("success", "If that email exists, a reset link has been sent.");
        } catch (Exception e) {
            req.setAttribute("error", "Something went wrong. Please try again.");
        }
        req.getRequestDispatcher("/views/auth/forgotPassword.jsp").forward(req, resp);
    }
}
