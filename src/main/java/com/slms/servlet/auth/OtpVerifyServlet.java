package com.slms.servlet.auth;

import com.slms.config.DBConfig;
import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;

@WebServlet("/verify-otp")
public class OtpVerifyServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("pendingUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/register");
            return;
        }
        req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("pendingUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/register");
            return;
        }

        String  enteredOtp = req.getParameter("otp");
        String  storedOtp  = (String)  session.getAttribute("pendingOtp");
        Long    expiry     = (Long)    session.getAttribute("otpExpiry");
        UserDTO pending    = (UserDTO) session.getAttribute("pendingUser");

        if (expiry == null || System.currentTimeMillis() > expiry) {
            clearSession(session);
            req.setAttribute("error", "OTP has expired. Please register again.");
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
            return;
        }

        if (enteredOtp == null || !enteredOtp.trim().equals(storedOtp)) {
            req.setAttribute("error", "Invalid OTP. Please try again.");
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
            return;
        }

        try {
            if ("TEACHER".equals(pending.getRole())) {
                handleTeacherRequest(req, resp, session, pending);
            } else {
                handleStudentRegistration(req, resp, session, pending);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Account creation failed: " + e.getMessage());
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
        }
    }

    private void handleTeacherRequest(HttpServletRequest req, HttpServletResponse resp,
                                       HttpSession session, UserDTO pending)
            throws Exception {
        String reason = (String) session.getAttribute("teacherReason");

        try (Connection con = DBConfig.getConnection()) {
            // Block duplicate pending requests
            try (PreparedStatement check = con.prepareStatement(
                    "SELECT id FROM teacher_requests WHERE (email=? OR username=?) AND status='PENDING'")) {
                check.setString(1, pending.getEmail());
                check.setString(2, pending.getUsername());
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    req.setAttribute("error",
                        "A pending teacher request with this email or username already exists. Please wait for admin review.");
                    req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
                    return;
                }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO teacher_requests (first_name, last_name, username, email, password_hash, reason) " +
                    "VALUES (?,?,?,?,?,?)")) {
                ps.setString(1, pending.getFirstName());
                ps.setString(2, pending.getLastName());
                ps.setString(3, pending.getUsername());
                ps.setString(4, pending.getEmail());
                ps.setString(5, pending.getPasswordHash());
                ps.setString(6, reason != null ? reason : "");
                ps.executeUpdate();
            }

            // Notify all active admins
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO notifications (user_id, message) " +
                    "SELECT id, ? FROM users WHERE role='ADMIN' AND is_active=TRUE")) {
                ps.setString(1, "New teacher request from " + pending.getFullName()
                    + " (" + pending.getEmail() + "). Review in Admin → Teacher Requests.");
                ps.executeUpdate();
            }
        }

        clearSession(session);
        req.getRequestDispatcher("/views/auth/pendingApproval.jsp").forward(req, resp);
    }

    private void handleStudentRegistration(HttpServletRequest req, HttpServletResponse resp,
                                            HttpSession session, UserDTO pending)
            throws Exception {
        userDAO.save(pending);
        clearSession(session);
        String fullName = pending.getFullName();
        String email    = pending.getEmail();
        new Thread(() -> EmailUtil.sendWelcome(email, fullName)).start();
        req.setAttribute("success", "Email verified! Your account is ready. Please log in.");
        req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
    }

    private void clearSession(HttpSession session) {
        session.removeAttribute("pendingUser");
        session.removeAttribute("pendingOtp");
        session.removeAttribute("otpExpiry");
        session.removeAttribute("teacherReason");
    }
}
