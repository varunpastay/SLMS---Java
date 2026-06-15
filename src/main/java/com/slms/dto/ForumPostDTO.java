package com.slms.dto;

import java.util.Date;
import java.util.List;

public class ForumPostDTO {
    private int id;
    private int courseId;
    private String courseTitle;
    private int authorId;
    private String authorName;
    private String title;
    private String body;
    private Date createdAt;
    private List<ForumCommentDTO> comments;
    private int commentCount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public List<ForumCommentDTO> getComments() { return comments; }
    public void setComments(List<ForumCommentDTO> comments) { this.comments = comments; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }
}
