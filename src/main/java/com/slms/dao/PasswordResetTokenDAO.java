package com.slms.dao;

import com.slms.dto.PasswordResetTokenDTO;
import java.sql.SQLException;

public interface PasswordResetTokenDAO {
    void save(PasswordResetTokenDTO token) throws SQLException;
    PasswordResetTokenDTO findByToken(String token) throws SQLException;
    void markUsed(String token) throws SQLException;
    void deleteExpired() throws SQLException;
}
