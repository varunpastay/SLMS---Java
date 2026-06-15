package com.slms.dao;

import com.slms.dto.QuizAttemptDTO;
import com.slms.dto.QuizDTO;
import com.slms.dto.QuizQuestionDTO;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public interface QuizDAO {
    void saveQuiz(QuizDTO quiz) throws SQLException;
    QuizDTO findQuizById(int id) throws SQLException;
    List<QuizDTO> findQuizzesByCourse(int courseId) throws SQLException;
    void updateQuiz(QuizDTO quiz) throws SQLException;
    void deleteQuiz(int id) throws SQLException;

    void saveQuestion(QuizQuestionDTO question) throws SQLException;
    List<QuizQuestionDTO> findQuestionsByQuiz(int quizId) throws SQLException;
    void deleteQuestion(int id) throws SQLException;

    int saveAttempt(QuizAttemptDTO attempt) throws SQLException;
    void saveAnswer(int attemptId, int questionId, char selectedOption) throws SQLException;
    QuizAttemptDTO findAttemptByStudentAndQuiz(int studentId, int quizId) throws SQLException;
    List<QuizAttemptDTO> findAttemptsByStudent(int studentId) throws SQLException;
    Map<Integer, Character> findAnswersByAttempt(int attemptId) throws SQLException;
}
