package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.FeedbackDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAOImpl implements FeedbackDAO {

    private FeedbackDTO mapRow(ResultSet rs) throws SQLException {
        FeedbackDTO f = new FeedbackDTO();
        f.setId(rs.getInt("id"));
        f.setStudentId(rs.getInt("student_id"));
        f.setTeacherId(rs.getInt("teacher_id"));
        f.setCourseId(rs.getInt("course_id"));
        f.setRating(rs.getInt("rating"));
        f.setComment(rs.getString("comment"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) f.setCreatedAt(ts);
        try { f.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        try { f.setTeacherName(rs.getString("teacher_name")); } catch (SQLException ignored) {}
        try { f.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return f;
    }

    private static final String BASE =
        "SELECT fb.*, " +
        "CONCAT(s.first_name,' ',s.last_name) AS student_name, " +
        "CONCAT(t.first_name,' ',t.last_name) AS teacher_name, " +
        "c.title AS course_title " +
        "FROM feedback fb " +
        "JOIN users s ON fb.student_id=s.id " +
        "JOIN users t ON fb.teacher_id=t.id " +
        "JOIN courses c ON fb.course_id=c.id ";

    @Override
    public void save(FeedbackDTO feedback) throws SQLException {
        String sql = "INSERT INTO feedback (student_id, teacher_id, course_id, rating, comment) VALUES (?,?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, feedback.getStudentId());
            ps.setInt(2, feedback.getTeacherId());
            ps.setInt(3, feedback.getCourseId());
            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getComment());
            ps.executeUpdate();
        }
    }

    @Override
    public FeedbackDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException {
        String sql = BASE + "WHERE fb.student_id=? AND fb.course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public List<FeedbackDTO> findByTeacher(int teacherId) throws SQLException {
        String sql = BASE + "WHERE fb.teacher_id=? ORDER BY fb.created_at DESC";
        List<FeedbackDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<FeedbackDTO> findByCourse(int courseId) throws SQLException {
        String sql = BASE + "WHERE fb.course_id=? ORDER BY fb.created_at DESC";
        List<FeedbackDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public double avgRatingForTeacher(int teacherId) throws SQLException {
        String sql = "SELECT AVG(rating) FROM feedback WHERE teacher_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0.0;
            }
        }
    }
}
