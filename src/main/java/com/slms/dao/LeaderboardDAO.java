package com.slms.dao;

import com.slms.dto.LeaderboardEntryDTO;
import java.sql.SQLException;
import java.util.List;

public interface LeaderboardDAO {
    List<LeaderboardEntryDTO> getLeaderboard(int limit) throws SQLException;
}
