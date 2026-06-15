package com.slms.dao;

import com.slms.dto.UserDTO;
import java.sql.SQLException;
import java.util.List;

public interface UserDAO {
    void save(UserDTO user) throws SQLException;
    UserDTO findById(int id) throws SQLException;
    UserDTO findByEmail(String email) throws SQLException;
    UserDTO findByUsername(String username) throws SQLException;
    List<UserDTO> findAll() throws SQLException;
    List<UserDTO> findByRole(String role) throws SQLException;
    void update(UserDTO user) throws SQLException;
    void updatePassword(int id, String passwordHash) throws SQLException;
    void delete(int id) throws SQLException;
    boolean existsByEmail(String email) throws SQLException;
    boolean existsByUsername(String username) throws SQLException;
    int countAll() throws SQLException;
    void toggleActive(int id) throws SQLException;
    List<UserDTO> searchByName(String query) throws SQLException;
}
