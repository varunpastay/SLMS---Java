package com.slms.dao;

import com.slms.dto.AssignmentDTO;
import java.sql.SQLException;
import java.util.List;

public interface AssignmentDAO {
    void save(AssignmentDTO assignment) throws SQLException;
    AssignmentDTO findById(int id) throws SQLException;
    List<AssignmentDTO> findByCourse(int courseId) throws SQLException;
    void update(AssignmentDTO assignment) throws SQLException;
    void delete(int id) throws SQLException;
    int countByCourse(int courseId) throws SQLException;
}
