package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.ChatMessageDTO;
import com.slms.dto.UserDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAOImpl implements ChatDAO {

    private ChatMessageDTO mapRow(ResultSet rs) throws SQLException {
        ChatMessageDTO m = new ChatMessageDTO();
        m.setId(rs.getInt("id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setReceiverId(rs.getInt("receiver_id"));
        m.setMessage(rs.getString("message"));
        m.setRead(rs.getBoolean("is_read"));
        Timestamp ts = rs.getTimestamp("sent_at");
        if (ts != null) m.setSentAt(ts);
        try { m.setSenderName(rs.getString("sender_name")); } catch (SQLException ignored) {}
        try { m.setReceiverName(rs.getString("receiver_name")); } catch (SQLException ignored) {}
        return m;
    }

    @Override
    public void save(ChatMessageDTO message) throws SQLException {
        String sql = "INSERT INTO chat_messages (sender_id, receiver_id, message) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, message.getSenderId());
            ps.setInt(2, message.getReceiverId());
            ps.setString(3, message.getMessage());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) message.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public List<ChatMessageDTO> findConversation(int userId1, int userId2) throws SQLException {
        String sql = "SELECT cm.*, " +
                     "CONCAT(s.first_name,' ',s.last_name) AS sender_name, " +
                     "CONCAT(r.first_name,' ',r.last_name) AS receiver_name " +
                     "FROM chat_messages cm " +
                     "JOIN users s ON cm.sender_id=s.id JOIN users r ON cm.receiver_id=r.id " +
                     "WHERE (cm.sender_id=? AND cm.receiver_id=?) OR (cm.sender_id=? AND cm.receiver_id=?) " +
                     "ORDER BY cm.sent_at ASC";
        List<ChatMessageDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1); ps.setInt(2, userId2);
            ps.setInt(3, userId2); ps.setInt(4, userId1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<UserDTO> findConversationPartners(int userId) throws SQLException {
        String sql = "SELECT DISTINCT u.id, u.username, u.first_name, u.last_name, u.profile_pic, u.role, " +
                     "u.email, u.password_hash, u.bio, u.is_active, u.date_joined " +
                     "FROM chat_messages cm JOIN users u ON " +
                     "(CASE WHEN cm.sender_id=? THEN cm.receiver_id ELSE cm.sender_id END) = u.id " +
                     "WHERE cm.sender_id=? OR cm.receiver_id=?";
        List<UserDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, userId); ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserDTO u = new UserDTO();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setFirstName(rs.getString("first_name"));
                    u.setLastName(rs.getString("last_name"));
                    u.setProfilePic(rs.getString("profile_pic"));
                    u.setRole(rs.getString("role"));
                    list.add(u);
                }
            }
        }
        return list;
    }

    @Override
    public void markAsRead(int senderId, int receiverId) throws SQLException {
        String sql = "UPDATE chat_messages SET is_read=TRUE WHERE sender_id=? AND receiver_id=? AND is_read=FALSE";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.executeUpdate();
        }
    }

    @Override
    public int countUnread(int receiverId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_read=FALSE";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
