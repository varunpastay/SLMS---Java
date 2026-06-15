package com.slms.dao;

import com.slms.dto.SubmissionDTO;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

public interface SubmissionDAO {
    void save(SubmissionDTO submission) throws SQLException;
    SubmissionDTO findById(int id) throws SQLException;
    SubmissionDTO findByAssignmentAndStudent(int assignmentId, int studentId) throws SQLException;
    List<SubmissionDTO> findByAssignment(int assignmentId) throws SQLException;
    List<SubmissionDTO> findByStudent(int studentId) throws SQLException;
    void grade(int id, BigDecimal marks, String feedback) throws SQLException;
    int countUngradedByTeacher(int teacherId) throws SQLException;
}
