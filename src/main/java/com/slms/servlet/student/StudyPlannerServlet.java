package com.slms.servlet.student;

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

@WebServlet("/study-planner")
public class StudyPlannerServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("goals".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                ArrayNode arr = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT g.id, g.title, g.subject, g.daily_minutes, g.target_date, g.status " +
                        "FROM study_goals g WHERE g.student_id=? ORDER BY g.target_date ASC, g.created_at DESC")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("id", rs.getInt("id"));
                        n.put("title", rs.getString("title"));
                        n.put("subject", rs.getString("subject") != null ? rs.getString("subject") : "");
                        n.put("targetDate", rs.getString("target_date") != null ? rs.getString("target_date") : "");
                        n.put("dailyMins", rs.getInt("daily_minutes"));
                        n.put("status", rs.getString("status") != null ? rs.getString("status") : "IN_PROGRESS");
                        arr.add(n);
                    }
                }
                resp.getWriter().write(arr.toString());
            } else if ("sessions".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                ArrayNode arr = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT id, subject, date, minutes_studied, notes FROM study_sessions " +
                        "WHERE student_id=? ORDER BY date DESC, created_at DESC LIMIT 30")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("id", rs.getInt("id"));
                        n.put("date", rs.getString("date"));
                        n.put("duration", rs.getInt("minutes_studied"));
                        n.put("subject", rs.getString("subject") != null ? rs.getString("subject") : "General");
                        n.put("notes", rs.getString("notes") != null ? rs.getString("notes") : "");
                        arr.add(n);
                    }
                }
                resp.getWriter().write(arr.toString());
            } else {
                // Page load
                List<Map<String,Object>> courses = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT c.id, c.title FROM courses c JOIN enrollments e ON c.id=e.course_id WHERE e.student_id=? ORDER BY c.title")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Map<String,Object> m = new LinkedHashMap<>();
                        m.put("id", rs.getInt("id")); m.put("title", rs.getString("title")); courses.add(m);
                    }
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COALESCE(SUM(minutes_studied),0) as week_mins FROM study_sessions " +
                        "WHERE student_id=? AND date >= DATE_SUB(CURDATE(),INTERVAL 7 DAY)")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) req.setAttribute("weekMins", rs.getInt("week_mins"));
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COALESCE(SUM(minutes_studied),0) as total_mins FROM study_sessions WHERE student_id=?")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) req.setAttribute("totalMins", rs.getInt("total_mins"));
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) as cnt FROM study_goals WHERE student_id=? AND status='COMPLETED'")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) req.setAttribute("goalsCompleted", rs.getInt("cnt"));
                }
                req.setAttribute("courses", courses);
                req.getRequestDispatcher("/views/student/studyPlanner.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("add-goal".equals(action)) {
                String title = req.getParameter("title");
                String subject = req.getParameter("subject");
                String targetDate = req.getParameter("targetDate");
                String mins = req.getParameter("dailyMins");
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO study_goals (student_id, title, subject, target_date, daily_minutes) VALUES (?,?,?,?,?)")) {
                    ps.setInt(1, user.getId());
                    ps.setString(2, title);
                    ps.setString(3, subject != null && !subject.isBlank() ? subject : null);
                    ps.setString(4, targetDate != null && !targetDate.isBlank() ? targetDate : null);
                    ps.setInt(5, mins != null && !mins.isBlank() ? Integer.parseInt(mins) : 60);
                    ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            } else if ("complete-goal".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE study_goals SET status='COMPLETED' WHERE id=? AND student_id=?")) {
                    ps.setInt(1, id); ps.setInt(2, user.getId()); ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            } else if ("delete-goal".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM study_goals WHERE id=? AND student_id=?")) {
                    ps.setInt(1, id); ps.setInt(2, user.getId()); ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            } else if ("log-session".equals(action)) {
                String subject = req.getParameter("subject");
                int mins = Integer.parseInt(req.getParameter("minutes"));
                String notes = req.getParameter("notes");
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO study_sessions (student_id, subject, date, minutes_studied, notes) VALUES (?,?,CURDATE(),?,?)")) {
                    ps.setInt(1, user.getId());
                    ps.setString(2, subject != null && !subject.isBlank() ? subject : null);
                    ps.setInt(3, mins); ps.setString(4, notes);
                    ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            }
        } catch (SQLException e) {
            ObjectNode err = mapper.createObjectNode(); err.put("error", e.getMessage());
            resp.getWriter().write(err.toString());
        }
    }
}
