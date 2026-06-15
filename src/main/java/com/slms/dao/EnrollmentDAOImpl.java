package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.EnrollmentDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EnrollmentDAOImpl implements EnrollmentDAO {

    private EnrollmentDTO mapRow(ResultSet rs) throws SQLException {
        EnrollmentDTO e = new EnrollmentDTO();
        e.setId(rs.getInt("id"));
        e.setStudentId(rs.getInt("student_id"));
        e.setCourseId(rs.getInt("course_id"));
        e.setCompleted(rs.getBoolean("completed"));
        Timestamp ts = rs.getTimestamp("enrolled_at");
        if (ts != null) e.setEnrolledAt(ts);
        try { e.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        try { e.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return e;
    }

    @Override
    public void save(EnrollmentDTO enrollment) throws SQLException {
        String sql = "INSERT INTO enrollments (student_id, course_id) VALUES (?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, enrollment.getStudentId());
            ps.setInt(2, enrollment.getCourseId());
            ps.executeUpdate();
        }
    }

    @Override
    public EnrollmentDTO findById(int id) throws SQLException {
        String sql = "SELECT e.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, c.title AS course_title " +
                     "FROM enrollments e JOIN users u ON e.student_id=u.id JOIN courses c ON e.course_id=c.id WHERE e.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public EnrollmentDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException {
        String sql = "SELECT e.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, c.title AS course_title " +
                     "FROM enrollments e JOIN users u ON e.student_id=u.id JOIN courses c ON e.course_id=c.id " +
                     "WHERE e.student_id=? AND e.course_id=?";
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
    public List<EnrollmentDTO> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT e.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, c.title AS course_title " +
                     "FROM enrollments e JOIN users u ON e.student_id=u.id JOIN courses c ON e.course_id=c.id " +
                     "WHERE e.student_id=? ORDER BY e.enrolled_at DESC";
        List<EnrollmentDTO> list = new ArrayList<>();
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
    public List<EnrollmentDTO> findByCourse(int courseId) throws SQLException {
        String sql = "SELECT e.*, CONCAT(u.first_name,' ',u.last_name) AS student_name, c.title AS course_title " +
                     "FROM enrollments e JOIN users u ON e.student_id=u.id JOIN courses c ON e.course_id=c.id " +
                     "WHERE e.course_id=? ORDER BY e.enrolled_at DESC";
        List<EnrollmentDTO> list = new ArrayList<>();
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
    public void markCompleted(int studentId, int courseId) throws SQLException {
        String sql = "UPDATE enrollments SET completed=TRUE WHERE student_id=? AND course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        }
    }

    @Override
    public boolean isEnrolled(int studentId, int courseId) throws SQLException {
        String sql = "SELECT 1 FROM enrollments WHERE student_id=? AND course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public int countByCourse(int courseId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM enrollments WHERE course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public int countByStudent(int studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM enrollments WHERE student_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM enrollments";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}
