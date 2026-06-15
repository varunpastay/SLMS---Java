package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.SubmissionDTO;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDAOImpl implements SubmissionDAO {

    private SubmissionDTO mapRow(ResultSet rs) throws SQLException {
        SubmissionDTO s = new SubmissionDTO();
        s.setId(rs.getInt("id"));
        s.setAssignmentId(rs.getInt("assignment_id"));
        s.setStudentId(rs.getInt("student_id"));
        s.setFilePath(rs.getString("file_path"));
        Timestamp sub = rs.getTimestamp("submitted_at");
        if (sub != null) s.setSubmittedAt(sub);
        BigDecimal marks = rs.getBigDecimal("marks_obtained");
        s.setMarksObtained(marks);
        s.setFeedback(rs.getString("feedback"));
        Timestamp graded = rs.getTimestamp("graded_at");
        if (graded != null) s.setGradedAt(graded);
        try { s.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        try { s.setAssignmentTitle(rs.getString("assignment_title")); } catch (SQLException ignored) {}
        return s;
    }

    @Override
    public void save(SubmissionDTO submission) throws SQLException {
        String sql = "INSERT INTO submissions (assignment_id, student_id, file_path) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, submission.getAssignmentId());
            ps.setInt(2, submission.getStudentId());
            ps.setString(3, submission.getFilePath());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) submission.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public SubmissionDTO findById(int id) throws SQLException {
        String sql = "SELECT s.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, a.title AS assignment_title " +
                     "FROM submissions s JOIN users u ON s.student_id=u.id JOIN assignments a ON s.assignment_id=a.id WHERE s.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public SubmissionDTO findByAssignmentAndStudent(int assignmentId, int studentId) throws SQLException {
        String sql = "SELECT s.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, a.title AS assignment_title " +
                     "FROM submissions s JOIN users u ON s.student_id=u.id JOIN assignments a ON s.assignment_id=a.id " +
                     "WHERE s.assignment_id=? AND s.student_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public List<SubmissionDTO> findByAssignment(int assignmentId) throws SQLException {
        String sql = "SELECT s.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, a.title AS assignment_title " +
                     "FROM submissions s JOIN users u ON s.student_id=u.id JOIN assignments a ON s.assignment_id=a.id " +
                     "WHERE s.assignment_id=? ORDER BY s.submitted_at DESC";
        List<SubmissionDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<SubmissionDTO> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT s.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, a.title AS assignment_title " +
                     "FROM submissions s JOIN users u ON s.student_id=u.id JOIN assignments a ON s.assignment_id=a.id " +
                     "WHERE s.student_id=? ORDER BY s.submitted_at DESC";
        List<SubmissionDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public void grade(int id, BigDecimal marks, String feedback) throws SQLException {
        String sql = "UPDATE submissions SET marks_obtained=?, feedback=?, graded_at=NOW() WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, marks);
            ps.setString(2, feedback);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    @Override
    public int countUngradedByTeacher(int teacherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM submissions s " +
                     "JOIN assignments a ON s.assignment_id=a.id " +
                     "JOIN courses c ON a.course_id=c.id " +
                     "WHERE c.teacher_id=? AND s.graded_at IS NULL";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
