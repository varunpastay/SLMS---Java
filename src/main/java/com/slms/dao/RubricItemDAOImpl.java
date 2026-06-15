package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.RubricItemDTO;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RubricItemDAOImpl implements RubricItemDAO {

    @Override
    public void save(RubricItemDTO item) throws SQLException {
        String sql = "INSERT INTO rubric_items (assignment_id, criterion, max_marks) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getAssignmentId());
            ps.setString(2, item.getCriterion());
            ps.setInt(3, item.getMaxMarks());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) { if (keys.next()) item.setId(keys.getInt(1)); }
        }
    }

    @Override
    public void deleteByAssignment(int assignmentId) throws SQLException {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM rubric_items WHERE assignment_id=?")) {
            ps.setInt(1, assignmentId); ps.executeUpdate();
        }
    }

    @Override
    public List<RubricItemDTO> findByAssignment(int assignmentId) throws SQLException {
        List<RubricItemDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM rubric_items WHERE assignment_id=? ORDER BY id")) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RubricItemDTO r = new RubricItemDTO();
                    r.setId(rs.getInt("id")); r.setAssignmentId(rs.getInt("assignment_id"));
                    r.setCriterion(rs.getString("criterion")); r.setMaxMarks(rs.getInt("max_marks"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    @Override
    public void saveGrade(int submissionId, int rubricItemId, BigDecimal marks) throws SQLException {
        String sql = "INSERT INTO rubric_grades (submission_id, rubric_item_id, marks_awarded) VALUES (?,?,?) " +
                     "ON DUPLICATE KEY UPDATE marks_awarded=VALUES(marks_awarded)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, submissionId); ps.setInt(2, rubricItemId); ps.setBigDecimal(3, marks);
            ps.executeUpdate();
        }
    }

    @Override
    public List<RubricItemDTO> findBySubmission(int submissionId) throws SQLException {
        String sql = "SELECT ri.*, COALESCE(rg.marks_awarded, 0) AS marks_awarded " +
                     "FROM rubric_items ri " +
                     "LEFT JOIN rubric_grades rg ON ri.id=rg.rubric_item_id AND rg.submission_id=? " +
                     "WHERE ri.assignment_id = (" +
                     "  SELECT assignment_id FROM submissions WHERE id=?) ORDER BY ri.id";
        List<RubricItemDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, submissionId); ps.setInt(2, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RubricItemDTO r = new RubricItemDTO();
                    r.setId(rs.getInt("id")); r.setAssignmentId(rs.getInt("assignment_id"));
                    r.setCriterion(rs.getString("criterion")); r.setMaxMarks(rs.getInt("max_marks"));
                    r.setMarksAwarded(rs.getBigDecimal("marks_awarded"));
                    list.add(r);
                }
            }
        }
        return list;
    }
}
