package com.slms.dao;

import com.slms.dto.RubricItemDTO;
import java.sql.SQLException;
import java.util.List;

public interface RubricItemDAO {
    void save(RubricItemDTO item) throws SQLException;
    void deleteByAssignment(int assignmentId) throws SQLException;
    List<RubricItemDTO> findByAssignment(int assignmentId) throws SQLException;
    void saveGrade(int submissionId, int rubricItemId, java.math.BigDecimal marks) throws SQLException;
    List<RubricItemDTO> findBySubmission(int submissionId) throws SQLException; // includes marksAwarded
}
