package com.slms.servlet.auth;

import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.EmailUtil;
import com.slms.util.PasswordUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;
    private final SecureRandom random = new SecureRandom();

    @Override
    public void init() {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (SessionUtil.getLoggedUser(req) != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username  = req.getParameter("username");
        String email     = req.getParameter("email");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirmPassword");
        String firstName = req.getParameter("firstName");
        String lastName  = req.getParameter("lastName");
        String role      = req.getParameter("role");
        String reason    = req.getParameter("teacherReason");

        if (username == null || username.isBlank() || email == null || email.isBlank()
                || password == null || password.isBlank()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if (!"STUDENT".equals(role) && !"TEACHER".equals(role)) {
            role = "STUDENT";
        }

        try {
            if (userDAO.existsByEmail(email)) {
                req.setAttribute("error", "An account with this email already exists.");
                req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
                return;
            }
            if (userDAO.existsByUsername(username)) {
                req.setAttribute("error", "Username is already taken.");
                req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
                return;
            }

            // Build pending user (not saved yet)
            UserDTO pending = new UserDTO();
            pending.setUsername(username);
            pending.setEmail(email);
            pending.setPasswordHash(PasswordUtil.hash(password));
            pending.setRole(role);
            pending.setFirstName(firstName);
            pending.setLastName(lastName);
            pending.setActive(true);

            // Generate 6-digit OTP
            String otp = String.format("%06d", random.nextInt(1_000_000));
            long expiry = System.currentTimeMillis() + 5 * 60 * 1000; // 5 minutes

            // Store in session
            HttpSession session = req.getSession(true);
            session.setAttribute("pendingUser", pending);
            session.setAttribute("pendingOtp", otp);
            session.setAttribute("otpExpiry", expiry);
            if ("TEACHER".equals(role)) {
                session.setAttribute("teacherReason", reason != null ? reason.trim() : "");
            }

            // Send OTP email asynchronously
            String fullName = ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
            final String otpCopy = otp;
            System.out.println("[OTP-DEBUG] Email=" + email + " OTP=" + otpCopy);
            new Thread(() -> EmailUtil.sendOtp(email, fullName, otpCopy)).start();

            resp.sendRedirect(req.getContextPath() + "/verify-otp");

        } catch (Exception e) {
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.getRequestDispatcher("/views/auth/register.jsp").forward(req, resp);
        }
    }
}
