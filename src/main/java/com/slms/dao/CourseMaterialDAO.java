package com.slms.dao;

import com.slms.dto.CourseMaterialDTO;
import java.sql.SQLException;
import java.util.List;

public interface CourseMaterialDAO {
    void save(CourseMaterialDTO material) throws SQLException;
    CourseMaterialDTO findById(int id) throws SQLException;
    List<CourseMaterialDTO> findByCourse(int courseId) throws SQLException;
    void delete(int id) throws SQLException;
}
