package com.slms.servlet.admin;

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

@WebServlet("/admin/course-approval")
public class CourseApprovalServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        try (Connection con = DBConfig.getConnection()) {
            List<Map<String,Object>> courses = new ArrayList<>();
            String statusFilter = req.getParameter("status");
            if (statusFilter == null || statusFilter.isBlank()) statusFilter = "PENDING";
            String sql = "SELECT c.*, CONCAT(u.first_name,' ',u.last_name) as teacher_name FROM courses c JOIN users u ON c.teacher_id=u.id WHERE c.approval_status=? ORDER BY c.created_at DESC";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, statusFilter);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("title", rs.getString("title"));
                    m.put("description", rs.getString("description")); m.put("teacherName", rs.getString("teacher_name"));
                    m.put("status", rs.getString("approval_status")); m.put("createdAt", rs.getString("created_at"));
                    m.put("rejectionNote", rs.getString("rejection_note") != null ? rs.getString("rejection_note") : "");
                    courses.add(m);
                }
            }
            req.setAttribute("courses", courses); req.setAttribute("statusFilter", statusFilter);

            // Counts
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT approval_status, COUNT(*) as cnt FROM courses GROUP BY approval_status")) {
                ResultSet rs = ps.executeQuery(); Map<String,Integer> counts = new HashMap<>();
                while (rs.next()) counts.put(rs.getString("approval_status"), rs.getInt("cnt"));
                req.setAttribute("counts", counts);
            }
            req.getRequestDispatcher("/views/admin/courseApproval.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        UserDTO admin = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");
        int courseId = Integer.parseInt(req.getParameter("courseId"));

        try (Connection con = DBConfig.getConnection()) {
            if ("approve".equals(action)) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE courses SET approval_status='APPROVED' WHERE id=?")) {
                    ps.setInt(1, courseId); ps.executeUpdate();
                }
                // Notify teacher
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT teacher_id, title FROM courses WHERE id=?")) {
                    ps.setInt(1, courseId); ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int teacherId = rs.getInt("teacher_id"); String title = rs.getString("title");
                        try (PreparedStatement ins = con.prepareStatement(
                                "INSERT INTO notifications (user_id, message) VALUES (?,?)")) {
                            ins.setInt(1, teacherId);
                            ins.setString(2, "✅ Your course \"" + title + "\" has been approved by admin.");
                            ins.executeUpdate();
                        }
                    }
                }
            } else if ("reject".equals(action)) {
                String note = req.getParameter("rejectionNote");
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE courses SET approval_status='REJECTED', rejection_note=? WHERE id=?")) {
                    ps.setString(1, note); ps.setInt(2, courseId); ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT teacher_id, title FROM courses WHERE id=?")) {
                    ps.setInt(1, courseId); ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int teacherId = rs.getInt("teacher_id"); String title = rs.getString("title");
                        try (PreparedStatement ins = con.prepareStatement(
                                "INSERT INTO notifications (user_id, message) VALUES (?,?)")) {
                            ins.setInt(1, teacherId);
                            ins.setString(2, "❌ Your course \"" + title + "\" was rejected. Note: " + (note != null ? note : ""));
                            ins.executeUpdate();
                        }
                    }
                }
            } else if ("submit".equals(action)) {
                // Teacher submits course for approval
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE courses SET approval_status='PENDING' WHERE id=?")) {
                    ps.setInt(1, courseId); ps.executeUpdate();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/course-approval");
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
