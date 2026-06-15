package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.QuizAttemptDTO;
import com.slms.dto.QuizDTO;
import com.slms.dto.QuizQuestionDTO;

import java.sql.*;
import java.util.*;

public class QuizDAOImpl implements QuizDAO {

    private QuizDTO mapQuiz(ResultSet rs) throws SQLException {
        QuizDTO q = new QuizDTO();
        q.setId(rs.getInt("id"));
        q.setCourseId(rs.getInt("course_id"));
        q.setTitle(rs.getString("title"));
        q.setDescription(rs.getString("description"));
        q.setTimeLimitMinutes(rs.getInt("time_limit_minutes"));
        q.setPassPercentage(rs.getInt("pass_percentage"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) q.setCreatedAt(ts);
        try { q.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        return q;
    }

    private QuizQuestionDTO mapQuestion(ResultSet rs) throws SQLException {
        QuizQuestionDTO q = new QuizQuestionDTO();
        q.setId(rs.getInt("id"));
        q.setQuizId(rs.getInt("quiz_id"));
        q.setQuestionText(rs.getString("question_text"));
        q.setOptionA(rs.getString("option_a"));
        q.setOptionB(rs.getString("option_b"));
        q.setOptionC(rs.getString("option_c"));
        q.setOptionD(rs.getString("option_d"));
        String opt = rs.getString("correct_option");
        if (opt != null && !opt.isEmpty()) q.setCorrectOption(opt.charAt(0));
        q.setMarks(rs.getInt("marks"));
        return q;
    }

    private QuizAttemptDTO mapAttempt(ResultSet rs) throws SQLException {
        QuizAttemptDTO a = new QuizAttemptDTO();
        a.setId(rs.getInt("id"));
        a.setQuizId(rs.getInt("quiz_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setScore(rs.getBigDecimal("score"));
        a.setPassed(rs.getBoolean("passed"));
        Timestamp ts = rs.getTimestamp("attempted_at");
        if (ts != null) a.setAttemptedAt(ts);
        try { a.setQuizTitle(rs.getString("quiz_title")); } catch (SQLException ignored) {}
        return a;
    }

    @Override
    public void saveQuiz(QuizDTO quiz) throws SQLException {
        String sql = "INSERT INTO quizzes (course_id, title, description, time_limit_minutes, pass_percentage) VALUES (?,?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, quiz.getCourseId());
            ps.setString(2, quiz.getTitle());
            ps.setString(3, quiz.getDescription());
            ps.setInt(4, quiz.getTimeLimitMinutes());
            ps.setInt(5, quiz.getPassPercentage());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) quiz.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public QuizDTO findQuizById(int id) throws SQLException {
        String sql = "SELECT q.*, c.title AS course_title FROM quizzes q JOIN courses c ON q.course_id=c.id WHERE q.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapQuiz(rs) : null;
            }
        }
    }

    @Override
    public List<QuizDTO> findQuizzesByCourse(int courseId) throws SQLException {
        String sql = "SELECT q.*, c.title AS course_title FROM quizzes q JOIN courses c ON q.course_id=c.id WHERE q.course_id=? ORDER BY q.created_at DESC";
        List<QuizDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapQuiz(rs));
            }
        }
        return list;
    }

    @Override
    public void updateQuiz(QuizDTO quiz) throws SQLException {
        String sql = "UPDATE quizzes SET title=?, description=?, time_limit_minutes=?, pass_percentage=? WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, quiz.getTitle());
            ps.setString(2, quiz.getDescription());
            ps.setInt(3, quiz.getTimeLimitMinutes());
            ps.setInt(4, quiz.getPassPercentage());
            ps.setInt(5, quiz.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteQuiz(int id) throws SQLException {
        String sql = "DELETE FROM quizzes WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void saveQuestion(QuizQuestionDTO question) throws SQLException {
        String sql = "INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, question.getQuizId());
            ps.setString(2, question.getQuestionText());
            ps.setString(3, question.getOptionA());
            ps.setString(4, question.getOptionB());
            ps.setString(5, question.getOptionC());
            ps.setString(6, question.getOptionD());
            ps.setString(7, String.valueOf(question.getCorrectOption()));
            ps.setInt(8, question.getMarks());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) question.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public List<QuizQuestionDTO> findQuestionsByQuiz(int quizId) throws SQLException {
        String sql = "SELECT * FROM quiz_questions WHERE quiz_id=? ORDER BY id";
        List<QuizQuestionDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapQuestion(rs));
            }
        }
        return list;
    }

    @Override
    public void deleteQuestion(int id) throws SQLException {
        String sql = "DELETE FROM quiz_questions WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public int saveAttempt(QuizAttemptDTO attempt) throws SQLException {
        String sql = "INSERT INTO quiz_attempts (quiz_id, student_id, score, passed) VALUES (?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, attempt.getQuizId());
            ps.setInt(2, attempt.getStudentId());
            ps.setBigDecimal(3, attempt.getScore());
            ps.setBoolean(4, attempt.isPassed());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    attempt.setId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    @Override
    public void saveAnswer(int attemptId, int questionId, char selectedOption) throws SQLException {
        String sql = "INSERT INTO quiz_answers (attempt_id, question_id, selected_option) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            ps.setInt(2, questionId);
            ps.setString(3, String.valueOf(selectedOption));
            ps.executeUpdate();
        }
    }

    @Override
    public QuizAttemptDTO findAttemptByStudentAndQuiz(int studentId, int quizId) throws SQLException {
        String sql = "SELECT qa.*, q.title AS quiz_title FROM quiz_attempts qa JOIN quizzes q ON qa.quiz_id=q.id " +
                     "WHERE qa.student_id=? AND qa.quiz_id=? ORDER BY qa.attempted_at DESC LIMIT 1";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAttempt(rs) : null;
            }
        }
    }

    @Override
    public List<QuizAttemptDTO> findAttemptsByStudent(int studentId) throws SQLException {
        String sql = "SELECT qa.*, q.title AS quiz_title FROM quiz_attempts qa JOIN quizzes q ON qa.quiz_id=q.id " +
                     "WHERE qa.student_id=? ORDER BY qa.attempted_at DESC";
        List<QuizAttemptDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAttempt(rs));
            }
        }
        return list;
    }

    @Override
    public List<QuizAttemptDTO> findAttemptsByQuiz(int quizId) throws SQLException {
        String sql = "SELECT qa.*, q.title AS quiz_title FROM quiz_attempts qa JOIN quizzes q ON qa.quiz_id=q.id " +
                     "WHERE qa.quiz_id=? ORDER BY qa.attempted_at DESC";
        List<QuizAttemptDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAttempt(rs));
            }
        }
        return list;
    }

    @Override
    public Map<Integer, Character> findAnswersByAttempt(int attemptId) throws SQLException {
        String sql = "SELECT question_id, selected_option FROM quiz_answers WHERE attempt_id=?";
        Map<Integer, Character> map = new HashMap<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String opt = rs.getString("selected_option");
                    if (opt != null && !opt.isEmpty())
                        map.put(rs.getInt("question_id"), opt.charAt(0));
                }
            }
        }
        return map;
    }
}
