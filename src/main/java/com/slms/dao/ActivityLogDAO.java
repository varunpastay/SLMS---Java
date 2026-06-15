package com.slms.dao;

import com.slms.dto.ActivityLogDTO;
import java.sql.SQLException;
import java.util.List;

public interface ActivityLogDAO {
    void log(int userId, String action, String details, String ip) throws SQLException;
    List<ActivityLogDTO> findRecent(int limit) throws SQLException;
    List<ActivityLogDTO> findByUser(int userId) throws SQLException;
}
