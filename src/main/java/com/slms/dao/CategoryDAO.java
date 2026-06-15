package com.slms.dao;

import com.slms.dto.CategoryDTO;
import java.sql.SQLException;
import java.util.List;

public interface CategoryDAO {
    List<CategoryDTO> findAll() throws SQLException;
    CategoryDTO findById(int id) throws SQLException;
    void save(CategoryDTO category) throws SQLException;
}
