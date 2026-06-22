package com.slms.servlet.admin;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.slms.config.DBConfig;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/dashboard-charts")
public class AdminDashboardChartsServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("data".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                ObjectNode out = mapper.createObjectNode();

                // User counts by role
                ObjectNode users = mapper.createObjectNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT role, COUNT(*) as cnt FROM users GROUP BY role")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) users.put(rs.getString("role"), rs.getInt("cnt"));
                }
                out.set("usersByRole", users);

                // New registrations last 7 days
                ArrayNode regs = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT DATE(date_joined) as d, COUNT(*) as cnt FROM users " +
                        "WHERE date_joined >= DATE_SUB(CURDATE(),INTERVAL 7 DAY) GROUP BY DATE(date_joined) ORDER BY d")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode(); n.put("date", rs.getString("d")); n.put("count", rs.getInt("cnt")); regs.add(n);
                    }
                }
                out.set("registrations", regs);

                // Top courses by enrollment
                ArrayNode topCourses = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT c.title, COUNT(e.id) as enrolled FROM courses c " +
                        "LEFT JOIN enrollments e ON c.id=e.course_id GROUP BY c.id, c.title ORDER BY enrolled DESC LIMIT 8")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode(); n.put("title", rs.getString("title")); n.put("enrolled", rs.getInt("enrolled")); topCourses.add(n);
                    }
                }
                out.set("topCourses", topCourses);

                // Submissions per day (last 7)
                ArrayNode subs = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT DATE(submitted_at) as d, COUNT(*) as cnt FROM submissions " +
                        "WHERE submitted_at >= DATE_SUB(CURDATE(),INTERVAL 7 DAY) GROUP BY DATE(submitted_at) ORDER BY d")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode(); n.put("date", rs.getString("d")); n.put("count", rs.getInt("cnt")); subs.add(n);
                    }
                } catch (SQLException ignored) {}
                out.set("submissions", subs);

                // Summary counts
                try (Statement st = con.createStatement()) {
                    ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users"); if (rs.next()) out.put("totalUsers", rs.getInt(1));
                }
                try (Statement st = con.createStatement()) {
                    ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM courses"); if (rs.next()) out.put("totalCourses", rs.getInt(1));
                }
                try (Statement st = con.createStatement()) {
                    ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM enrollments"); if (rs.next()) out.put("totalEnrollments", rs.getInt(1));
                }
                try (Statement st = con.createStatement()) {
                    ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM teacher_requests WHERE status='PENDING'");
                    if (rs.next()) out.put("pendingTeachers", rs.getInt(1));
                } catch (SQLException ignored) {}

                resp.getWriter().write(out.toString());
            } else {
                req.getRequestDispatcher("/views/admin/adminDashboardCharts.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
