package com.slms.servlet.auth;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;

    @Override
    public void init() {
        userDAO  = new UserDAOImpl();
        tokenDAO = new PasswordResetTokenDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String token = req.getParameter("token");
        try {
            PasswordResetTokenDTO t = tokenDAO.findByToken(token);
            if (t == null || t.isUsed() || t.isExpired()) {
                req.setAttribute("error", "This reset link is invalid or has expired.");
            } else {
                req.setAttribute("token", token);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Something went wrong.");
        }
        req.getRequestDispatcher("/views/auth/resetPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String token    = req.getParameter("token");
        String newPass  = req.getParameter("newPassword");
        String confirm  = req.getParameter("confirmPassword");

        try {
            PasswordResetTokenDTO t = tokenDAO.findByToken(token);
            if (t == null || t.isUsed() || t.isExpired()) {
                req.setAttribute("error", "Invalid or expired reset link.");
                req.getRequestDispatcher("/views/auth/resetPassword.jsp").forward(req, resp);
                return;
            }
            if (!newPass.equals(confirm)) {
                req.setAttribute("token", token);
                req.setAttribute("error", "Passwords do not match.");
                req.getRequestDispatcher("/views/auth/resetPassword.jsp").forward(req, resp);
                return;
            }
            if (newPass.length() < 6) {
                req.setAttribute("token", token);
                req.setAttribute("error", "Password must be at least 6 characters.");
                req.getRequestDispatcher("/views/auth/resetPassword.jsp").forward(req, resp);
                return;
            }
            userDAO.updatePassword(t.getUserId(), PasswordUtil.hash(newPass));
            tokenDAO.markUsed(token);
            resp.sendRedirect(req.getContextPath() + "/login?msg=passwordReset");
        } catch (Exception e) {
            req.setAttribute("error", "Reset failed. Please try again.");
            req.getRequestDispatcher("/views/auth/resetPassword.jsp").forward(req, resp);
        }
    }
}
