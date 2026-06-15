package com.slms.dao;

import com.slms.dto.ForumCommentDTO;
import com.slms.dto.ForumPostDTO;
import java.sql.SQLException;
import java.util.List;

public interface ForumDAO {
    void savePost(ForumPostDTO post) throws SQLException;
    ForumPostDTO findPostById(int id) throws SQLException;
    List<ForumPostDTO> findAllPosts() throws SQLException;
    List<ForumPostDTO> findPostsByCourse(int courseId) throws SQLException;
    void deletePost(int id) throws SQLException;

    void saveComment(ForumCommentDTO comment) throws SQLException;
    List<ForumCommentDTO> findCommentsByPost(int postId) throws SQLException;
    void deleteComment(int id) throws SQLException;
}
