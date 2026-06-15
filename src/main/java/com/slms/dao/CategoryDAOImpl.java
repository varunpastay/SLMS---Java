package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.CategoryDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAOImpl implements CategoryDAO {

    private CategoryDTO mapRow(ResultSet rs) throws SQLException {
        CategoryDTO c = new CategoryDTO();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setIcon(rs.getString("icon"));
        return c;
    }

    @Override
    public List<CategoryDTO> findAll() throws SQLException {
        String sql = "SELECT * FROM categories ORDER BY name";
        List<CategoryDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    @Override
    public CategoryDTO findById(int id) throws SQLException {
        String sql = "SELECT * FROM categories WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public void save(CategoryDTO category) throws SQLException {
        String sql = "INSERT INTO categories (name, icon) VALUES (?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getIcon());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) category.setId(keys.getInt(1));
            }
        }
    }
}
