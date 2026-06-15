package com.slms.dao;

import com.slms.config.DBConfig;
import com.slms.dto.ForumCommentDTO;
import com.slms.dto.ForumPostDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ForumDAOImpl implements ForumDAO {

    private ForumPostDTO mapPost(ResultSet rs) throws SQLException {
        ForumPostDTO p = new ForumPostDTO();
        p.setId(rs.getInt("id"));
        p.setCourseId(rs.getInt("course_id"));
        p.setAuthorId(rs.getInt("author_id"));
        p.setTitle(rs.getString("title"));
        p.setBody(rs.getString("body"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts);
        try { p.setAuthorName(rs.getString("author_name")); } catch (SQLException ignored) {}
        try { p.setCourseTitle(rs.getString("course_title")); } catch (SQLException ignored) {}
        try { p.setCommentCount(rs.getInt("comment_count")); } catch (SQLException ignored) {}
        return p;
    }

    private ForumCommentDTO mapComment(ResultSet rs) throws SQLException {
        ForumCommentDTO c = new ForumCommentDTO();
        c.setId(rs.getInt("id"));
        c.setPostId(rs.getInt("post_id"));
        c.setAuthorId(rs.getInt("author_id"));
        c.setBody(rs.getString("body"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) c.setCreatedAt(ts);
        try { c.setAuthorName(rs.getString("author_name")); } catch (SQLException ignored) {}
        return c;
    }

    private static final String POST_SELECT =
        "SELECT fp.*, CONCAT(u.first_name,' ',u.last_name) AS author_name, " +
        "c.title AS course_title, " +
        "(SELECT COUNT(*) FROM forum_comments fc WHERE fc.post_id=fp.id) AS comment_count " +
        "FROM forum_posts fp JOIN users u ON fp.author_id=u.id " +
        "LEFT JOIN courses c ON fp.course_id=c.id ";

    @Override
    public void savePost(ForumPostDTO post) throws SQLException {
        String sql = "INSERT INTO forum_posts (course_id, author_id, title, body) VALUES (?,?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (post.getCourseId() > 0) ps.setInt(1, post.getCourseId()); else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, post.getAuthorId());
            ps.setString(3, post.getTitle());
            ps.setString(4, post.getBody());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) post.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public ForumPostDTO findPostById(int id) throws SQLException {
        String sql = POST_SELECT + "WHERE fp.id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPost(rs) : null;
            }
        }
    }

    @Override
    public List<ForumPostDTO> findAllPosts() throws SQLException {
        String sql = POST_SELECT + "ORDER BY fp.created_at DESC";
        List<ForumPostDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapPost(rs));
        }
        return list;
    }

    @Override
    public List<ForumPostDTO> findPostsByCourse(int courseId) throws SQLException {
        String sql = POST_SELECT + "WHERE fp.course_id=? ORDER BY fp.created_at DESC";
        List<ForumPostDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapPost(rs));
            }
        }
        return list;
    }

    @Override
    public void deletePost(int id) throws SQLException {
        String sql = "DELETE FROM forum_posts WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void saveComment(ForumCommentDTO comment) throws SQLException {
        String sql = "INSERT INTO forum_comments (post_id, author_id, body) VALUES (?,?,?)";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, comment.getPostId());
            ps.setInt(2, comment.getAuthorId());
            ps.setString(3, comment.getBody());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) comment.setId(keys.getInt(1));
            }
        }
    }

    @Override
    public List<ForumCommentDTO> findCommentsByPost(int postId) throws SQLException {
        String sql = "SELECT fc.*, CONCAT(u.first_name,' ',u.last_name) AS author_name " +
                     "FROM forum_comments fc JOIN users u ON fc.author_id=u.id WHERE fc.post_id=? ORDER BY fc.created_at ASC";
        List<ForumCommentDTO> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapComment(rs));
            }
        }
        return list;
    }

    @Override
    public void deleteComment(int id) throws SQLException {
        String sql = "DELETE FROM forum_comments WHERE id=?";
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
