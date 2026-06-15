package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.CertificateDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CertificateDAOImpl implements CertificateDAO {

    private CertificateDTO mapRow(ResultSet rs) throws SQLException {
        CertificateDTO cert = new CertificateDTO();
        cert.setId(rs.getInt("id"));
        cert.setStudentId(rs.getInt("student_id"));
        cert.setCourseId(rs.getInt("course_id"));
        cert.setCertificateCode(rs.getString("certificate_code"));
        Timestamp ts = rs.getTimestamp("issued_at");
        if (ts != null) cert.setIssuedAt(ts);
        try { cert.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        try { cert.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        try { cert.setTeacherName(rs.getString("teacher_name")); } catch (SQLException ignored) {}
        return cert;
    }

    private static final String BASE =
        "SELECT cert.*, " +
        "CONCAT(s.first_name,' ',s.last_name) AS student_name, " +
        "c.title AS course_title, " +
        "CONCAT(t.first_name,' ',t.last_name) AS teacher_name " +
        "FROM certificates cert " +
        "JOIN users s ON cert.student_id=s.id " +
        "JOIN courses c ON cert.course_id=c.id " +
        "JOIN users t ON c.teacher_id=t.id ";

    @Override
    public void save(CertificateDTO certificate) throws SQLException {
        String sql = "INSERT INTO certificates (student_id, course_id, certificate_code) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, certificate.getStudentId());
            ps.setInt(2, certificate.getCourseId());
            ps.setString(3, certificate.getCertificateCode());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) certificate.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public CertificateDTO findById(int id) throws SQLException {
        String sql = BASE + "WHERE cert.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public CertificateDTO findByCode(String code) throws SQLException {
        String sql = BASE + "WHERE cert.certificate_code=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public CertificateDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException {
        String sql = BASE + "WHERE cert.student_id=? AND cert.course_id=?";
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
    public List<CertificateDTO> findByStudent(int studentId) throws SQLException {
        String sql = BASE + "WHERE cert.student_id=? ORDER BY cert.issued_at DESC";
        List<CertificateDTO> list = new ArrayList<>();
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
    public boolean exists(int studentId, int courseId) throws SQLException {
        String sql = "SELECT 1 FROM certificates WHERE student_id=? AND course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
