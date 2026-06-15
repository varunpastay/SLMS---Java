package com.slms.dto;

import java.util.Date;

public class PasswordResetTokenDTO {
    private int id;
    private int userId;
    private String token;
    private Date expiresAt;
    private boolean used;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public Date getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Date expiresAt) { this.expiresAt = expiresAt; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }
    public boolean isExpired() { return expiresAt != null && expiresAt.before(new Date()); }
}
