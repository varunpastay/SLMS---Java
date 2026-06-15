package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.PasswordResetTokenDTO;

import java.sql.*;

public class PasswordResetTokenDAOImpl implements PasswordResetTokenDAO {

    @Override
    public void save(PasswordResetTokenDTO t) throws SQLException {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, t.getUserId());
            ps.setString(2, t.getToken());
            ps.setTimestamp(3, new Timestamp(t.getExpiresAt().getTime()));
            ps.executeUpdate();
        }
    }

    @Override
    public PasswordResetTokenDTO findByToken(String token) throws SQLException {
        String sql = "SELECT * FROM password_reset_tokens WHERE token=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                PasswordResetTokenDTO t = new PasswordResetTokenDTO();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setToken(rs.getString("token"));
                t.setUsed(rs.getBoolean("used"));
                Timestamp ts = rs.getTimestamp("expires_at");
                if (ts != null) t.setExpiresAt(ts);
                return t;
            }
        }
    }

    @Override
    public void markUsed(String token) throws SQLException {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement("UPDATE password_reset_tokens SET used=TRUE WHERE token=?")) {
            ps.setString(1, token); ps.executeUpdate();
        }
    }

    @Override
    public void deleteExpired() throws SQLException {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM password_reset_tokens WHERE expires_at < NOW() OR used=TRUE")) {
            ps.executeUpdate();
        }
    }
}
