package com.slms.servlet;

import com.slms.config.DBConfig;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/search")
public class GlobalSearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (SessionUtil.getLoggedUser(req) == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        UserDTO user = SessionUtil.getLoggedUser(req);
        String query = req.getParameter("q");
        req.setAttribute("query", query);

        if (query == null || query.trim().isEmpty()) {
            req.getRequestDispatcher("/views/globalSearch.jsp").forward(req, resp); return;
        }
        String q = "%" + query.trim() + "%";

        try (Connection con = DBConfig.getConnection()) {
            List<Map<String,Object>> courses = new ArrayList<>();
            // Search courses (role-based)
            String courseSql;
            if ("ADMIN".equals(user.getRole())) {
                courseSql = "SELECT id, title, description, 'course' as type FROM courses WHERE title LIKE ? OR description LIKE ? LIMIT 10";
            } else if ("TEACHER".equals(user.getRole())) {
                courseSql = "SELECT id, title, description, 'course' as type FROM courses WHERE (title LIKE ? OR description LIKE ?) AND teacher_id=" + user.getId() + " LIMIT 10";
            } else {
                courseSql = "SELECT c.id, c.title, c.description, 'course' as type FROM courses c JOIN enrollments e ON c.id=e.course_id WHERE (c.title LIKE ? OR c.description LIKE ?) AND e.student_id=" + user.getId() + " LIMIT 10";
            }
            try (PreparedStatement ps = con.prepareStatement(courseSql)) {
                ps.setString(1, q); ps.setString(2, q);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("title", rs.getString("title"));
                    m.put("description", rs.getString("description") != null ? rs.getString("description") : ""); courses.add(m);
                }
            }
            req.setAttribute("courses", courses);

            // Search users (admin only)
            if ("ADMIN".equals(user.getRole())) {
                List<Map<String,Object>> users = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT id, CONCAT(first_name,' ',last_name) as name, email, username, role FROM users " +
                        "WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR username LIKE ? LIMIT 10")) {
                    ps.setString(1, q); ps.setString(2, q); ps.setString(3, q); ps.setString(4, q);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Map<String,Object> m = new LinkedHashMap<>();
                        m.put("id", rs.getInt("id")); m.put("name", rs.getString("name"));
                        m.put("email", rs.getString("email")); m.put("role", rs.getString("role")); users.add(m);
                    }
                }
                req.setAttribute("users", users);
            }

            // Search assignments
            List<Map<String,Object>> assignments = new ArrayList<>();
            String asgSql = "ADMIN".equals(user.getRole()) ?
                "SELECT a.id, a.title, c.title as course FROM assignments a JOIN courses c ON a.course_id=c.id WHERE a.title LIKE ? LIMIT 10" :
                "TEACHER".equals(user.getRole()) ?
                "SELECT a.id, a.title, c.title as course FROM assignments a JOIN courses c ON a.course_id=c.id WHERE a.title LIKE ? AND c.teacher_id=" + user.getId() + " LIMIT 10" :
                "SELECT a.id, a.title, c.title as course FROM assignments a JOIN courses c ON a.course_id=c.id JOIN enrollments e ON c.id=e.course_id WHERE a.title LIKE ? AND e.student_id=" + user.getId() + " LIMIT 10";
            try (PreparedStatement ps = con.prepareStatement(asgSql)) {
                ps.setString(1, q);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("title", rs.getString("title")); m.put("course", rs.getString("course")); assignments.add(m);
                }
            }
            req.setAttribute("assignments", assignments);

        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/views/globalSearch.jsp").forward(req, resp);
    }
}
