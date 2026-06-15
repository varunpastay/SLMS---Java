package com.slms.dao;

import com.slms.dto.FeedbackDTO;
import java.sql.SQLException;
import java.util.List;

public interface FeedbackDAO {
    void save(FeedbackDTO feedback) throws SQLException;
    FeedbackDTO findByStudentAndCourse(int studentId, int courseId) throws SQLException;
    List<FeedbackDTO> findByTeacher(int teacherId) throws SQLException;
    List<FeedbackDTO> findByCourse(int courseId) throws SQLException;
    double avgRatingForTeacher(int teacherId) throws SQLException;
}
