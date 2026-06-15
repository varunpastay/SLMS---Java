package com.slms.servlet.auth;

import com.slms.dao.ActivityLogDAO;
import com.slms.dao.ActivityLogDAOImpl;
import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.PasswordUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;
    private ActivityLogDAO activityLogDAO;

    @Override
    public void init() {
        userDAO        = new UserDAOImpl();
        activityLogDAO = new ActivityLogDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (SessionUtil.getLoggedUser(req) != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UserDTO user = userDAO.findByEmail(email);
            if (user == null || !PasswordUtil.verify(password, user.getPasswordHash())) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
                return;
            }
            if (!user.isActive()) {
                req.setAttribute("error", "Your account has been deactivated.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
                return;
            }
            SessionUtil.setLoggedUser(req, user);
            activityLogDAO.log(user.getId(), "LOGIN", "User logged in", req.getRemoteAddr());
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } catch (Exception e) {
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
        }
    }
}
