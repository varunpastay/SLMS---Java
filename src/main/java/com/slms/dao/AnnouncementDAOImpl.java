package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.AnnouncementDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AnnouncementDAOImpl implements AnnouncementDAO {

    private AnnouncementDTO map(ResultSet rs) throws SQLException {
        AnnouncementDTO a = new AnnouncementDTO();
        a.setId(rs.getInt("id"));
        a.setCourseId(rs.getInt("course_id"));
        a.setAuthorId(rs.getInt("author_id"));
        a.setTitle(rs.getString("title"));
        a.setBody(rs.getString("body"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) a.setCreatedAt(ts);
        try { a.setAuthorName(rs.getString("author_name")); } catch (SQLException ignored) {}
        try { a.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return a;
    }

    @Override
    public void save(AnnouncementDTO a) throws SQLException {
        String sql = "INSERT INTO announcements (course_id, author_id, title, body) VALUES (?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, a.getCourseId());
            ps.setInt(2, a.getAuthorId());
            ps.setString(3, a.getTitle());
            ps.setString(4, a.getBody());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) a.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public void delete(int id) throws SQLException {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM announcements WHERE id=?")) {
            ps.setInt(1, id); ps.executeUpdate();
        }
    }

    @Override
    public List<AnnouncementDTO> findByCourse(int courseId) throws SQLException {
        String sql = "SELECT a.*, CONCAT(u.first_name,' ',u.last_name) AS author_name, c.title AS course_title " +
                     "FROM announcements a JOIN users u ON a.author_id=u.id JOIN courses c ON a.course_id=c.id " +
                     "WHERE a.course_id=? ORDER BY a.created_at DESC";
        List<AnnouncementDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(map(rs)); }
        }
        return list;
    }

    @Override
    public List<AnnouncementDTO> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT a.*, CONCAT(u.first_name,' ',u.last_name) AS author_name, c.title AS course_title " +
                     "FROM announcements a JOIN users u ON a.author_id=u.id JOIN courses c ON a.course_id=c.id " +
                     "JOIN enrollments e ON e.course_id=a.course_id AND e.student_id=? " +
                     "ORDER BY a.created_at DESC LIMIT 20";
        List<AnnouncementDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) list.add(map(rs)); }
        }
        return list;
    }
}
