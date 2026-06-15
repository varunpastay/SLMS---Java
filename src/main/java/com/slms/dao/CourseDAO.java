package com.slms.dao;

import com.slms.dto.CourseDTO;
import java.sql.SQLException;
import java.util.List;

public interface CourseDAO {
    void save(CourseDTO course) throws SQLException;
    CourseDTO findById(int id) throws SQLException;
    List<CourseDTO> findAll() throws SQLException;
    List<CourseDTO> findAllPublished() throws SQLException;
    List<CourseDTO> findByTeacher(int teacherId) throws SQLException;
    List<CourseDTO> findByCategory(int categoryId) throws SQLException;
    List<CourseDTO> search(String keyword) throws SQLException;
    void update(CourseDTO course) throws SQLException;
    void delete(int id) throws SQLException;
    int countAll() throws SQLException;
    int countByTeacher(int teacherId) throws SQLException;
}
