package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.CourseMaterialDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseMaterialDAOImpl implements CourseMaterialDAO {

    private CourseMaterialDTO mapRow(ResultSet rs) throws SQLException {
        CourseMaterialDTO m = new CourseMaterialDTO();
        m.setId(rs.getInt("id"));
        m.setCourseId(rs.getInt("course_id"));
        m.setTitle(rs.getString("title"));
        m.setFilePath(rs.getString("file_path"));
        m.setMaterialType(rs.getString("material_type"));
        Timestamp ts = rs.getTimestamp("uploaded_at");
        if (ts != null) m.setUploadedAt(ts);
        try { m.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return m;
    }

    @Override
    public void save(CourseMaterialDTO material) throws SQLException {
        String sql = "INSERT INTO course_materials (course_id, title, file_path, material_type) VALUES (?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, material.getCourseId());
            ps.setString(2, material.getTitle());
            ps.setString(3, material.getFilePath());
            ps.setString(4, material.getMaterialType());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) material.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public CourseMaterialDTO findById(int id) throws SQLException {
        String sql = "SELECT cm.*, c.title AS course_title FROM course_materials cm JOIN courses c ON cm.course_id=c.id WHERE cm.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public List<CourseMaterialDTO> findByCourse(int courseId) throws SQLException {
        String sql = "SELECT cm.*, c.title AS course_title FROM course_materials cm JOIN courses c ON cm.course_id=c.id WHERE cm.course_id=? ORDER BY cm.uploaded_at DESC";
        List<CourseMaterialDTO> list = new ArrayList<>();
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
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM course_materials WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
