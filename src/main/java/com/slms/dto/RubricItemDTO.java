package com.slms.dto;

import java.math.BigDecimal;

public class RubricItemDTO {
    private int id;
    private int assignmentId;
    private String criterion;
    private int maxMarks;
    private BigDecimal marksAwarded; // used when displaying a graded submission

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }
    public String getCriterion() { return criterion; }
    public void setCriterion(String criterion) { this.criterion = criterion; }
    public int getMaxMarks() { return maxMarks; }
    public void setMaxMarks(int maxMarks) { this.maxMarks = maxMarks; }
    public BigDecimal getMarksAwarded() { return marksAwarded; }
    public void setMarksAwarded(BigDecimal marksAwarded) { this.marksAwarded = marksAwarded; }
}
