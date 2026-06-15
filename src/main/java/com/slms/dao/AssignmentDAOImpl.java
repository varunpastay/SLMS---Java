package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.AssignmentDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssignmentDAOImpl implements AssignmentDAO {

    private AssignmentDTO mapRow(ResultSet rs) throws SQLException {
        AssignmentDTO a = new AssignmentDTO();
        a.setId(rs.getInt("id"));
        a.setCourseId(rs.getInt("course_id"));
        a.setTitle(rs.getString("title"));
        a.setDescription(rs.getString("description"));
        a.setMaxMarks(rs.getInt("max_marks"));
        Timestamp due = rs.getTimestamp("due_date");
        if (due != null) a.setDueDate(due);
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) a.setCreatedAt(created);
        try { a.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return a;
    }

    @Override
    public void save(AssignmentDTO assignment) throws SQLException {
        String sql = "INSERT INTO assignments (course_id, title, description, due_date, max_marks) VALUES (?,?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, assignment.getCourseId());
            ps.setString(2, assignment.getTitle());
            ps.setString(3, assignment.getDescription());
            if (assignment.getDueDate() != null)
                ps.setTimestamp(4, new Timestamp(assignment.getDueDate().getTime()));
            else
                ps.setNull(4, Types.TIMESTAMP);
            ps.setInt(5, assignment.getMaxMarks());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) assignment.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public AssignmentDTO findById(int id) throws SQLException {
        String sql = "SELECT a.*, c.title AS course_title FROM assignments a JOIN courses c ON a.course_id=c.id WHERE a.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public List<AssignmentDTO> findByCourse(int courseId) throws SQLException {
        String sql = "SELECT a.*, c.title AS course_title FROM assignments a JOIN courses c ON a.course_id=c.id WHERE a.course_id=? ORDER BY a.due_date ASC";
        List<AssignmentDTO> list = new ArrayList<>();
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
    public void update(AssignmentDTO assignment) throws SQLException {
        String sql = "UPDATE assignments SET title=?, description=?, due_date=?, max_marks=? WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, assignment.getTitle());
            ps.setString(2, assignment.getDescription());
            if (assignment.getDueDate() != null)
                ps.setTimestamp(3, new Timestamp(assignment.getDueDate().getTime()));
            else
                ps.setNull(3, Types.TIMESTAMP);
            ps.setInt(4, assignment.getMaxMarks());
            ps.setInt(5, assignment.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM assignments WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public int countByCourse(int courseId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM assignments WHERE course_id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
