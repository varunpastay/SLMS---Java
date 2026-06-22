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

@WebServlet("/teacher/analytics")
public class StudentAnalyticsServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER")) return;
        UserDTO teacher = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("data".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                ObjectNode out = mapper.createObjectNode();

                // Grade distribution (using submissions.marks_obtained)
                ArrayNode gradesDist = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT CASE WHEN s.marks_obtained>=90 THEN 'A (90-100)' WHEN s.marks_obtained>=75 THEN 'B (75-89)' " +
                        "WHEN s.marks_obtained>=60 THEN 'C (60-74)' WHEN s.marks_obtained>=40 THEN 'D (40-59)' ELSE 'F (<40)' END as band, " +
                        "COUNT(*) as cnt FROM submissions s JOIN assignments a ON s.assignment_id=a.id " +
                        "WHERE a.course_id=? AND s.marks_obtained IS NOT NULL GROUP BY band ORDER BY band")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("band", rs.getString("band")); n.put("count", rs.getInt("cnt")); gradesDist.add(n);
                    }
                }
                out.set("gradeDistribution", gradesDist);

                // Top students
                ArrayNode top = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT CONCAT(u.first_name,' ',u.last_name) as name, AVG(s.marks_obtained) as avg_grade, COUNT(s.id) as submissions " +
                        "FROM submissions s JOIN assignments a ON s.assignment_id=a.id JOIN users u ON s.student_id=u.id " +
                        "WHERE a.course_id=? AND s.marks_obtained IS NOT NULL GROUP BY u.id, u.first_name, u.last_name ORDER BY avg_grade DESC LIMIT 10")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("name", rs.getString("name"));
                        n.put("avg", Math.round(rs.getDouble("avg_grade")*10)/10.0);
                        n.put("submissions", rs.getInt("submissions")); top.add(n);
                    }
                }
                out.set("topStudents", top);

                // Assignment averages
                ArrayNode assignments = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT a.title, AVG(s.marks_obtained) as avg, COUNT(s.id) as cnt FROM assignments a " +
                        "LEFT JOIN submissions s ON a.id=s.assignment_id WHERE a.course_id=? GROUP BY a.id, a.title ORDER BY a.created_at")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("title", rs.getString("title")); n.put("avg", Math.round(rs.getDouble("avg")*10)/10.0);
                        n.put("submissions", rs.getInt("cnt")); assignments.add(n);
                    }
                }
                out.set("assignments", assignments);

                // Attendance rate
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(CASE WHEN status='PRESENT' THEN 1 END) as p, COUNT(*) as t " +
                        "FROM attendance WHERE course_id=?")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int p = rs.getInt("p"), t = rs.getInt("t");
                        out.put("attendanceRate", t > 0 ? Math.round(p*100.0/t) : 0);
                    }
                }

                // Enrollment count
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) as cnt FROM enrollments WHERE course_id=?")) {
                    ps.setInt(1, courseId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) out.put("enrolled", rs.getInt("cnt"));
                }

                resp.getWriter().write(out.toString());
            } else {
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
                req.getRequestDispatcher("/views/teacher/studentAnalytics.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
