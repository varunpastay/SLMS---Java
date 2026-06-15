package com.slms.dto;

import java.math.BigDecimal;
import java.util.Date;

public class SubmissionDTO {
    private int id;
    private int assignmentId;
    private String assignmentTitle;
    private int studentId;
    private String studentName;
    private String filePath;
    private Date submittedAt;
    private BigDecimal marksObtained;
    private String feedback;
    private Date gradedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public String getAssignmentTitle() { return assignmentTitle; }
    public void setAssignmentTitle(String assignmentTitle) { this.assignmentTitle = assignmentTitle; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public Date getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Date submittedAt) { this.submittedAt = submittedAt; }

    public BigDecimal getMarksObtained() { return marksObtained; }
    public void setMarksObtained(BigDecimal marksObtained) { this.marksObtained = marksObtained; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public Date getGradedAt() { return gradedAt; }
    public void setGradedAt(Date gradedAt) { this.gradedAt = gradedAt; }

    public boolean isGraded() { return gradedAt != null; }
}
