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

@WebServlet("/progress-dashboard")
public class ProgressDashboardServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("data".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                ObjectNode out = mapper.createObjectNode();

                // Course grades (from submissions)
                ArrayNode grades = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT c.title, AVG(s.marks_obtained) as avg_grade FROM submissions s " +
                        "JOIN assignments a ON s.assignment_id=a.id JOIN courses c ON a.course_id=c.id " +
                        "WHERE s.student_id=? AND s.marks_obtained IS NOT NULL GROUP BY c.id,c.title ORDER BY c.title")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("course", rs.getString("title")); n.put("avg", rs.getDouble("avg_grade")); grades.add(n);
                    }
                }
                out.set("grades", grades);

                // Quiz scores (NoteWise)
                ArrayNode quizzes = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT DATE(attempted_at) as d, score, total FROM notewise_quizzes " +
                        "WHERE student_id=? ORDER BY attempted_at DESC LIMIT 10")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("date", rs.getString("d")); n.put("score", rs.getInt("score"));
                        n.put("total", rs.getInt("total")); quizzes.add(n);
                    }
                } catch (SQLException ignored) {}
                out.set("quizzes", quizzes);

                // Study hours per day (last 7 days)
                ArrayNode study = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT session_date as d, SUM(duration_minutes) as mins FROM study_sessions " +
                        "WHERE student_id=? AND session_date >= DATE_SUB(CURDATE(),INTERVAL 7 DAY) " +
                        "GROUP BY session_date ORDER BY session_date")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("date", rs.getString("d")); n.put("hours", rs.getDouble("mins")/60.0); study.add(n);
                    }
                } catch (SQLException ignored) {}
                out.set("studyHours", study);

                // OMR scores
                ArrayNode omr = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT ev.title, r.marks_obtained as score, ev.total_marks FROM omr_results r " +
                        "JOIN omr_evaluations ev ON r.evaluation_id=ev.id " +
                        "WHERE r.student_id=? LIMIT 10")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("title", rs.getString("title")); n.put("score", rs.getDouble("score"));
                        n.put("total", rs.getDouble("total_marks")); omr.add(n);
                    }
                } catch (SQLException ignored) {}
                out.set("omrScores", omr);

                // Summary stats
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(DISTINCT e.course_id) as courses, " +
                        "COALESCE((SELECT AVG(s.marks_obtained) FROM submissions s JOIN assignments a ON s.assignment_id=a.id " +
                        "WHERE s.student_id=? AND s.marks_obtained IS NOT NULL),0) as avg_grade " +
                        "FROM enrollments e WHERE e.student_id=?")) {
                    ps.setInt(1, user.getId()); ps.setInt(2, user.getId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        out.put("enrolledCourses", rs.getInt("courses"));
                        out.put("overallAvg", Math.round(rs.getDouble("avg_grade") * 10.0) / 10.0);
                    }
                }
                resp.getWriter().write(out.toString());
            } else {
                req.getRequestDispatcher("/views/student/progressDashboard.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
