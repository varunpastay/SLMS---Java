package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.CourseDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAOImpl implements CourseDAO {

    private CourseDTO mapRow(ResultSet rs) throws SQLException {
        CourseDTO c = new CourseDTO();
        c.setId(rs.getInt("id"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        c.setTeacherId(rs.getInt("teacher_id"));
        c.setTeacherName(rs.getString("teacher_name"));
        c.setCategoryId(rs.getInt("category_id"));
        c.setCategoryName(rs.getString("category_name"));
        c.setThumbnail(rs.getString("thumbnail"));
        c.setYoutubeUrl(rs.getString("youtube_url"));
        c.setPublished(rs.getBoolean("is_published"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) c.setCreatedAt(ts);
        try { c.setEnrollmentCount(rs.getInt("enrollment_count")); } catch (SQLException ignored) {}
        return c;
    }

    private static final String BASE_SELECT =
        "SELECT c.*, CONCAT(u.first_name,' ',u.last_name) AS teacher_name, " +
        "cat.name AS category_name, " +
        "(SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id) AS enrollment_count " +
        "FROM courses c " +
        "LEFT JOIN users u ON c.teacher_id = u.id " +
        "LEFT JOIN categories cat ON c.category_id = cat.id ";

    @Override
    public void save(CourseDTO course) throws SQLException {
        String sql = "INSERT INTO courses (title, description, teacher_id, category_id, thumbnail, youtube_url, is_published) VALUES (?,?,?,?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, course.getTitle());
            ps.setString(2, course.getDescription());
            ps.setInt(3, course.getTeacherId());
            if (course.getCategoryId() > 0) ps.setInt(4, course.getCategoryId()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, course.getThumbnail());
            ps.setString(6, course.getYoutubeUrl());
            ps.setBoolean(7, course.isPublished());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) course.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public CourseDTO findById(int id) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.id = ?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public List<CourseDTO> findAll() throws SQLException {
        String sql = BASE_SELECT + "ORDER BY c.created_at DESC";
        List<CourseDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    @Override
    public List<CourseDTO> findAllPublished() throws SQLException {
        String sql = BASE_SELECT + "WHERE c.is_published = TRUE ORDER BY c.created_at DESC";
        List<CourseDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    @Override
    public List<CourseDTO> findByTeacher(int teacherId) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.teacher_id = ? ORDER BY c.created_at DESC";
        List<CourseDTO> list = new ArrayList<>();
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
    public List<CourseDTO> findByCategory(int categoryId) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.category_id = ? AND c.is_published = TRUE ORDER BY c.created_at DESC";
        List<CourseDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<CourseDTO> search(String keyword) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.is_published = TRUE AND (c.title LIKE ? OR c.description LIKE ?) ORDER BY c.created_at DESC";
        List<CourseDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public void update(CourseDTO course) throws SQLException {
        String sql = "UPDATE courses SET title=?, description=?, category_id=?, thumbnail=?, youtube_url=?, is_published=? WHERE id=? AND teacher_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, course.getTitle());
            ps.setString(2, course.getDescription());
            if (course.getCategoryId() > 0) ps.setInt(3, course.getCategoryId()); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, course.getThumbnail());
            ps.setString(5, course.getYoutubeUrl());
            ps.setBoolean(6, course.isPublished());
            ps.setInt(7, course.getId());
            ps.setInt(8, course.getTeacherId());
            ps.executeUpdate();
        }
    }

    @Override
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM courses WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM courses";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    @Override
    public int countByTeacher(int teacherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM courses WHERE teacher_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
