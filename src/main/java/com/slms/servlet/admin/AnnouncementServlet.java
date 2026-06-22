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

@WebServlet("/admin/announcements")
public class AnnouncementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        try (Connection con = DBConfig.getConnection()) {
            List<Map<String,Object>> list = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT b.*, CONCAT(u.first_name,' ',u.last_name) as sender_name FROM broadcasts b " +
                    "JOIN users u ON b.sender_id=u.id ORDER BY b.sent_at DESC")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("title", rs.getString("title"));
                    m.put("message", rs.getString("message")); m.put("targetRole", rs.getString("target_role"));
                    m.put("senderName", rs.getString("sender_name")); m.put("createdAt", rs.getString("sent_at"));
                    list.add(m);
                }
            }
            req.setAttribute("announcements", list);
            req.getRequestDispatcher("/views/admin/announcements.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;
        UserDTO admin = SessionUtil.getLoggedUser(req);
        String action = req.getParameter("action");

        try (Connection con = DBConfig.getConnection()) {
            if ("send".equals(action)) {
                String title = req.getParameter("title");
                String message = req.getParameter("message");
                String targetRole = req.getParameter("targetRole");

                // Insert into broadcasts
                int broadcastId;
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO broadcasts (sender_id, title, message, target_role) VALUES (?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, admin.getId()); ps.setString(2, title);
                    ps.setString(3, message); ps.setString(4, targetRole);
                    ps.executeUpdate();
                    ResultSet rs = ps.getGeneratedKeys(); rs.next(); broadcastId = rs.getInt(1);
                }

                // Create notifications for target users
                String userSql = "ALL".equals(targetRole) ?
                    "SELECT id FROM users WHERE id != ?" :
                    "SELECT id FROM users WHERE role=? AND id != ?";
                try (PreparedStatement ps = con.prepareStatement(userSql)) {
                    if ("ALL".equals(targetRole)) { ps.setInt(1, admin.getId()); }
                    else { ps.setString(1, targetRole); ps.setInt(2, admin.getId()); }
                    ResultSet rs = ps.executeQuery();
                    try (PreparedStatement ins = con.prepareStatement(
                            "INSERT INTO notifications (user_id, message) VALUES (?,?)")) {
                        while (rs.next()) {
                            ins.setInt(1, rs.getInt("id"));
                            ins.setString(2, "📢 " + title + ": " + message);
                            ins.addBatch();
                        }
                        ins.executeBatch();
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/announcements?success=Announcement+sent");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM broadcasts WHERE id=?")) {
                    ps.setInt(1, id); ps.executeUpdate();
                }
                resp.sendRedirect(req.getContextPath() + "/admin/announcements");
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }
}
