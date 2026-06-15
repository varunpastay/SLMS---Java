package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.LeaderboardEntryDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaderboardDAOImpl implements LeaderboardDAO {

    @Override
    public List<LeaderboardEntryDTO> getLeaderboard(int limit) throws SQLException {
        String sql =
            "SELECT u.id AS student_id, CONCAT(u.first_name,' ',u.last_name) AS student_name, u.profile_pic, " +
            "COALESCE(SUM(s.marks_obtained), 0) + COALESCE(SUM(qa.score), 0) AS total_score, " +
            "COUNT(DISTINCT qa.id) AS quizzes_passed, " +
            "COUNT(DISTINCT s.id) AS assignments_graded " +
            "FROM users u " +
            "LEFT JOIN submissions s ON u.id=s.student_id AND s.graded_at IS NOT NULL " +
            "LEFT JOIN quiz_attempts qa ON u.id=qa.student_id AND qa.passed=TRUE " +
            "WHERE u.role='STUDENT' AND u.is_active=TRUE " +
            "GROUP BY u.id, u.first_name, u.last_name, u.profile_pic " +
            "ORDER BY total_score DESC " +
            "LIMIT ?";

        List<LeaderboardEntryDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                int rank = 1;
                while (rs.next()) {
                    LeaderboardEntryDTO entry = new LeaderboardEntryDTO();
                    entry.setRank(rank++);
                    entry.setStudentId(rs.getInt("student_id"));
                    entry.setStudentName(rs.getString("student_name"));
                    entry.setProfilePic(rs.getString("profile_pic"));
                    entry.setTotalScore(rs.getBigDecimal("total_score"));
                    entry.setQuizzesPassed(rs.getInt("quizzes_passed"));
                    entry.setAssignmentsGraded(rs.getInt("assignments_graded"));
                    list.add(entry);
                }
            }
        }
        return list;
    }
}
