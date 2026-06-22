package com.slms.servlet.student;

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

@WebServlet("/my-attendance")
public class AttendanceTrackerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);

        try (Connection con = DBConfig.getConnection()) {
            // Per-course attendance summary
            List<Map<String,Object>> courses = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT c.id, c.title, " +
                    "COUNT(CASE WHEN a.status='PRESENT' THEN 1 END) as present, " +
                    "COUNT(CASE WHEN a.status='ABSENT' THEN 1 END) as absent, " +
                    "COUNT(CASE WHEN a.status='LATE' THEN 1 END) as late, " +
                    "COUNT(a.id) as total " +
                    "FROM enrollments e JOIN courses c ON e.course_id=c.id " +
                    "LEFT JOIN attendance a ON a.student_id=e.student_id AND a.course_id=c.id " +
                    "WHERE e.student_id=? GROUP BY c.id, c.title ORDER BY c.title")) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    int present = rs.getInt("present"), total = rs.getInt("total");
                    m.put("courseId", rs.getInt("id")); m.put("title", rs.getString("title"));
                    m.put("present", present); m.put("absent", rs.getInt("absent"));
                    m.put("late", rs.getInt("late")); m.put("total", total);
                    m.put("pct", total > 0 ? Math.round(present * 100.0 / total) : -1);
                    courses.add(m);
                }
            }

            // Recent attendance records
            List<Map<String,Object>> records = new ArrayList<>();
            String courseFilter = req.getParameter("courseId");
            String sql = "SELECT a.date, a.status, c.title as course FROM attendance a " +
                         "JOIN courses c ON a.course_id=c.id WHERE a.student_id=?";
            if (courseFilter != null && !courseFilter.isBlank()) sql += " AND a.course_id=" + Integer.parseInt(courseFilter);
            sql += " ORDER BY a.date DESC LIMIT 30";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("date", rs.getString("date")); m.put("status", rs.getString("status"));
                    m.put("course", rs.getString("course")); records.add(m);
                }
            }

            req.setAttribute("coursesSummary", courses);
            req.setAttribute("records", records);
            req.setAttribute("selectedCourse", courseFilter);
            req.getRequestDispatcher("/views/student/attendanceTracker.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
