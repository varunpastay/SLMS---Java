package com.slms.dto;

import java.math.BigDecimal;

public class LeaderboardEntryDTO {
    private int rank;
    private int studentId;
    private String studentName;
    private String profilePic;
    private BigDecimal totalScore;
    private int quizzesPassed;
    private int assignmentsGraded;

    public int getRank() { return rank; }
    public void setRank(int rank) { this.rank = rank; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getProfilePic() { return profilePic; }
    public void setProfilePic(String profilePic) { this.profilePic = profilePic; }

    public BigDecimal getTotalScore() { return totalScore; }
    public void setTotalScore(BigDecimal totalScore) { this.totalScore = totalScore; }

    public int getQuizzesPassed() { return quizzesPassed; }
    public void setQuizzesPassed(int quizzesPassed) { this.quizzesPassed = quizzesPassed; }

    public int getAssignmentsGraded() { return assignmentsGraded; }
    public void setAssignmentsGraded(int assignmentsGraded) { this.assignmentsGraded = assignmentsGraded; }
}
