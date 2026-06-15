package com.slms.dao;

import com.slms.dto.AnnouncementDTO;
import java.sql.SQLException;
import java.util.List;

public interface AnnouncementDAO {
    void save(AnnouncementDTO a) throws SQLException;
    void delete(int id) throws SQLException;
    List<AnnouncementDTO> findByCourse(int courseId) throws SQLException;
    List<AnnouncementDTO> findByStudent(int studentId) throws SQLException; // across all enrolled courses
}
