package com.slms.servlet.teacher;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
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

@WebServlet("/teacher/attendance")
public class AttendanceServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER")) return;
        UserDTO teacher = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("summary".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                ArrayNode arr = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT u.id, CONCAT(u.first_name,' ',u.last_name) as name, u.email, " +
                        "COUNT(CASE WHEN a.status='PRESENT' THEN 1 END) as present, " +
                        "COUNT(CASE WHEN a.status='ABSENT' THEN 1 END) as absent, " +
                        "COUNT(a.id) as total " +
                        "FROM enrollments e JOIN users u ON e.student_id=u.id " +
                        "LEFT JOIN attendance a ON a.student_id=u.id AND a.course_id=e.course_id " +
                        "WHERE e.course_id=? GROUP BY u.id, u.first_name, u.last_name, u.email ORDER BY u.first_name")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("id", rs.getInt("id")); n.put("name", rs.getString("name"));
                        n.put("email", rs.getString("email"));
                        int present = rs.getInt("present"), total = rs.getInt("total");
                        n.put("present", present); n.put("absent", rs.getInt("absent"));
                        n.put("total", total);
                        n.put("pct", total > 0 ? Math.round(present*100.0/total) : 0);
                        arr.add(n);
                    }
                }
                resp.getWriter().write(arr.toString());
            } else if ("records".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                String date = req.getParameter("date");
                ArrayNode arr = mapper.createArrayNode();
                String sql = "SELECT u.id as studentId, CONCAT(u.first_name,' ',u.last_name) as name, a.status, a.date " +
                             "FROM enrollments e JOIN users u ON e.student_id=u.id " +
                             "LEFT JOIN attendance a ON a.student_id=u.id AND a.course_id=e.course_id";
                if (date != null && !date.isBlank()) sql += " AND a.date='" + date.replaceAll("[^0-9-]", "") + "'";
                sql += " WHERE e.course_id=? ORDER BY u.first_name";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("studentId", rs.getInt("studentId")); n.put("name", rs.getString("name"));
                        n.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                        n.put("date", rs.getString("date") != null ? rs.getString("date") : "");
                        arr.add(n);
                    }
                }
                resp.getWriter().write(arr.toString());
            } else {
                // Page load
                List<Map<String,Object>> courses = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT id, title FROM courses WHERE teacher_id=? ORDER BY title")) {
                    ps.setInt(1, teacher.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Map<String,Object> m = new LinkedHashMap<>();
                        m.put("id", rs.getInt("id")); m.put("title", rs.getString("title")); courses.add(m);
                    }
                }
                req.setAttribute("courses", courses);
                req.getRequestDispatcher("/views/teacher/attendance.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER")) return;
        UserDTO teacher = SessionUtil.getLoggedUser(req);
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("mark".equals(action)) {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                String date = req.getParameter("date").replaceAll("[^0-9-]", "");
                String status = req.getParameter("status");
                upsertAttendance(con, studentId, courseId, date, status, teacher.getId());
                resp.getWriter().write("{\"ok\":true}");
            } else if ("bulk-mark".equals(action)) {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                String date = req.getParameter("date").replaceAll("[^0-9-]", "");
                String[] studentIds = req.getParameterValues("studentId");
                String[] statuses = req.getParameterValues("status");
                if (studentIds != null) {
                    for (int i = 0; i < studentIds.length; i++) {
                        upsertAttendance(con, Integer.parseInt(studentIds[i]), courseId, date, statuses[i], teacher.getId());
                    }
                }
                resp.getWriter().write("{\"ok\":true}");
            }
        } catch (SQLException e) {
            ObjectNode err = mapper.createObjectNode(); err.put("error", e.getMessage());
            resp.getWriter().write(err.toString());
        }
    }

    private void upsertAttendance(Connection con, int studentId, int courseId, String date, String status, int teacherId) throws SQLException {
        // Try UPDATE first, then INSERT if no rows affected
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE attendance SET status=?, marked_by=? WHERE student_id=? AND course_id=? AND date=?")) {
            ps.setString(1, status); ps.setInt(2, teacherId);
            ps.setInt(3, studentId); ps.setInt(4, courseId); ps.setString(5, date);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                try (PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO attendance (course_id, student_id, date, status, marked_by) VALUES (?,?,?,?,?)")) {
                    ins.setInt(1, courseId); ins.setInt(2, studentId);
                    ins.setString(3, date); ins.setString(4, status); ins.setInt(5, teacherId);
                    ins.executeUpdate();
                }
            }
        }
    }
}
