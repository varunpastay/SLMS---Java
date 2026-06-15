package com.slms.dao;

import com.slms.dto.EnrollmentDTO;
import java.sql.SQLException;
import java.util.List;

public interface EnrollmentDAO {
    void save(EnrollmentDTO enrollment) throws SQLException;
    EnrollmentDTO findById(int id) throws SQLException;
    EnrollmentDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException;
    List<EnrollmentDTO> findByStudent(int studentId) throws SQLException;
    List<EnrollmentDTO> findByCourse(int courseId) throws SQLException;
    void markCompleted(int studentId, int courseId) throws SQLException;
    boolean isEnrolled(int studentId, int courseId) throws SQLException;
    int countByCourse(int courseId) throws SQLException;
    int countByStudent(int studentId) throws SQLException;
    int countAll() throws SQLException;
}
