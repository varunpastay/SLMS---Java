package com.slms.servlet.auth;

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

        String enteredOtp = req.getParameter("otp");
        String storedOtp  = (String)  session.getAttribute("pendingOtp");
        Long   expiry     = (Long)    session.getAttribute("otpExpiry");
        UserDTO pending   = (UserDTO) session.getAttribute("pendingUser");

        // Check expiry
        if (expiry == null || System.currentTimeMillis() > expiry) {
            session.removeAttribute("pendingUser");
            session.removeAttribute("pendingOtp");
            session.removeAttribute("otpExpiry");
            req.setAttribute("error", "OTP has expired. Please register again.");
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
            return;
        }

        // Check OTP
        if (enteredOtp == null || !enteredOtp.trim().equals(storedOtp)) {
            req.setAttribute("error", "Invalid OTP. Please try again.");
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
            return;
        }

        // OTP correct — save user
        try {
            userDAO.save(pending);

            // Clear OTP session data
            session.removeAttribute("pendingUser");
            session.removeAttribute("pendingOtp");
            session.removeAttribute("otpExpiry");

            // Send welcome email asynchronously
            String fullName = pending.getFullName();
            String email = pending.getEmail();
            new Thread(() -> EmailUtil.sendWelcome(email, fullName)).start();

            req.setAttribute("success", "Email verified! Your account is ready. Please log in.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", "Account creation failed: " + e.getMessage());
            req.getRequestDispatcher("/views/auth/verifyOtp.jsp").forward(req, resp);
        }
    }
}
