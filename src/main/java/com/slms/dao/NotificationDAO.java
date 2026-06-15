package com.slms.dao;

import com.slms.dto.NotificationDTO;
import java.sql.SQLException;
import java.util.List;

public interface NotificationDAO {
    void save(NotificationDTO notification) throws SQLException;
    List<NotificationDTO> findByUser(int userId) throws SQLException;
    void markAllRead(int userId) throws SQLException;
    int countUnread(int userId) throws SQLException;
    void delete(int id) throws SQLException;
}
