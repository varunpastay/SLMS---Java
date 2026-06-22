package com.slms.servlet.admin;

import com.slms.config.DBConfig;
import com.slms.dao.UserDAO;
import com.slms.dao.UserDAOImpl;
import com.slms.dto.UserDTO;
import com.slms.util.EmailUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/teacher-requests")
public class AdminTeacherRequestServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;

        List<Map<String, Object>> requests = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT tr.*, u.username AS reviewer_name " +
                "FROM teacher_requests tr " +
                "LEFT JOIN users u ON tr.reviewed_by = u.id " +
                "ORDER BY (tr.status = 'PENDING') DESC, tr.created_at DESC")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> r = new LinkedHashMap<>();
                r.put("id",           rs.getInt("id"));
                r.put("firstName",    rs.getString("first_name"));
                r.put("lastName",     rs.getString("last_name"));
                r.put("username",     rs.getString("username"));
                r.put("email",        rs.getString("email"));
                r.put("reason",       rs.getString("reason"));
                r.put("status",       rs.getString("status"));
                r.put("createdAt",    rs.getString("created_at"));
                r.put("reviewerName", rs.getString("reviewer_name"));
                r.put("reviewedAt",   rs.getString("reviewed_at"));
                requests.add(r);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        req.setAttribute("requests", requests);
        req.getRequestDispatcher("/views/admin/teacherRequests.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        UserDTO admin = SessionUtil.getLoggedUser(req);

        int    id     = Integer.parseInt(req.getParameter("id"));
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("approve".equals(action)) {
                approveRequest(con, id, admin, req, resp);
            } else if ("reject".equals(action)) {
                rejectRequest(con, id, admin);
                resp.sendRedirect(req.getContextPath() + "/admin/teacher-requests?msg=rejected");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void approveRequest(Connection con, int id, UserDTO admin,
                                 HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        // Fetch the pending request
        String firstName, lastName, username, email, passwordHash;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM teacher_requests WHERE id=? AND status='PENDING'")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                resp.sendRedirect(req.getContextPath() + "/admin/teacher-requests?msg=not_found");
                return;
            }
            firstName    = rs.getString("first_name");
            lastName     = rs.getString("last_name");
            username     = rs.getString("username");
            email        = rs.getString("email");
            passwordHash = rs.getString("password_hash");
        }

        // Guard: email or username already taken
        if (userDAO.existsByEmail(email) || userDAO.existsByUsername(username)) {
            markReviewed(con, id, admin.getId(), "REJECTED");
            resp.sendRedirect(req.getContextPath() + "/admin/teacher-requests?msg=duplicate");
            return;
        }

        // Create the teacher account
        UserDTO teacher = new UserDTO();
        teacher.setFirstName(firstName);
        teacher.setLastName(lastName);
        teacher.setUsername(username);
        teacher.setEmail(email);
        teacher.setPasswordHash(passwordHash);
        teacher.setRole("TEACHER");
        teacher.setActive(true);
        userDAO.save(teacher);

        markReviewed(con, id, admin.getId(), "APPROVED");

        // Welcome email
        String fullName = (firstName + " " + lastName).trim();
        new Thread(() -> EmailUtil.sendWelcome(email, fullName)).start();

        resp.sendRedirect(req.getContextPath() + "/admin/teacher-requests?msg=approved");
    }

    private void rejectRequest(Connection con, int id, UserDTO admin) throws SQLException {
        markReviewed(con, id, admin.getId(), "REJECTED");
    }

    private void markReviewed(Connection con, int id, int adminId, String status) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE teacher_requests SET status=?, reviewed_by=?, reviewed_at=NOW() WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, adminId);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }
}
