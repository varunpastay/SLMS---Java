package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.ActivityLogDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAOImpl implements ActivityLogDAO {

    @Override
    public void log(int userId, String action, String details, String ip) {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO activity_logs (user_id, action, details, ip_address) VALUES (?,?,?,?)")) {
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, details);
            ps.setString(4, ip);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ActivityLog] Failed: " + e.getMessage());
        }
    }

    @Override
    public List<ActivityLogDTO> findRecent(int limit) throws SQLException {
        String sql = "SELECT al.*, CONCAT(u.first_name,' ',u.last_name) AS user_name " +
                     "FROM activity_logs al LEFT JOIN users u ON al.user_id=u.id " +
                     "ORDER BY al.created_at DESC LIMIT ?";
        List<ActivityLogDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(map(rs)); }
        }
        return list;
    }

    @Override
    public List<ActivityLogDTO> findByUser(int userId) throws SQLException {
        String sql = "SELECT al.*, CONCAT(u.first_name,' ',u.last_name) AS user_name " +
                     "FROM activity_logs al LEFT JOIN users u ON al.user_id=u.id " +
                     "WHERE al.user_id=? ORDER BY al.created_at DESC LIMIT 50";
        List<ActivityLogDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(map(rs)); }
        }
        return list;
    }

    private ActivityLogDTO map(ResultSet rs) throws SQLException {
        ActivityLogDTO a = new ActivityLogDTO();
        a.setId(rs.getInt("id"));
        a.setUserId(rs.getInt("user_id"));
        a.setAction(rs.getString("action"));
        a.setDetails(rs.getString("details"));
        a.setIpAddress(rs.getString("ip_address"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) a.setCreatedAt(ts);
        try { a.setUserName(rs.getString("user_name")); } catch (SQLException ignored) {}
        return a;
    }
}
