package com.slms.dto;

import java.math.BigDecimal;
import java.util.Date;

public class QuizAttemptDTO {
    private int id;
    private int quizId;
    private String quizTitle;
    private int studentId;
    private String studentName;
    private BigDecimal score;
    private boolean passed;
    private Date attemptedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuizId() { return quizId; }
    public void setQuizId(int quizId) { this.quizId = quizId; }

    public String getQuizTitle() { return quizTitle; }
    public void setQuizTitle(String quizTitle) { this.quizTitle = quizTitle; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }

    public boolean isPassed() { return passed; }
    public void setPassed(boolean passed) { this.passed = passed; }

    public Date getAttemptedAt() { return attemptedAt; }
    public void setAttemptedAt(Date attemptedAt) { this.attemptedAt = attemptedAt; }
}
