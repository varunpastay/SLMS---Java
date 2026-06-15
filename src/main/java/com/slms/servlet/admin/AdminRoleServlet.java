package com.slms.servlet.admin;

import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import java.util.List;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/user/role")
public class AdminRoleServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;

        try {
            int userId     = Integer.parseInt(req.getParameter("userId"));
            String newRole = req.getParameter("role");

            if (!List.of("STUDENT", "TEACHER", "ADMIN").contains(newRole)) {
                resp.sendRedirect(req.getContextPath() + "/dashboard?error=invalidRole");
                return;
            }

            UserDTO user = userDAO.findById(userId);
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard?error=userNotFound");
                return;
            }

            user.setRole(newRole);
            userDAO.update(user);

            resp.sendRedirect(req.getContextPath() + "/dashboard?roleUpdated=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
