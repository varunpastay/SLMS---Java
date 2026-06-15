package com.slms.servlet.forum;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/forum")
public class ForumServlet extends HttpServlet {

    private ForumDAO forumDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() {
        forumDAO  = new ForumDAOImpl();
        courseDAO = new CourseDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("post".equals(action)) {
                int postId = Integer.parseInt(req.getParameter("id"));
                ForumPostDTO post = forumDAO.findPostById(postId);
                if (post == null) { resp.sendError(404); return; }
                List<ForumCommentDTO> comments = forumDAO.findCommentsByPost(postId);
                post.setComments(comments);
                req.setAttribute("post", post);
                req.getRequestDispatcher("/views/forum/postDetail.jsp").forward(req, resp);

            } else {
                String courseParam = req.getParameter("courseId");
                List<ForumPostDTO> posts;
                if (courseParam != null && !courseParam.isBlank()) {
                    int courseId = Integer.parseInt(courseParam);
                    posts = forumDAO.findPostsByCourse(courseId);
                    req.setAttribute("filterCourse", courseDAO.findById(courseId));
                } else {
                    posts = forumDAO.findAllPosts();
                }
                List<CourseDTO> courses = courseDAO.findAllPublished();
                req.setAttribute("posts", posts);
                req.setAttribute("courses", courses);
                req.getRequestDispatcher("/views/forum/forumList.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");
        UserDTO user = SessionUtil.getLoggedUser(req);

        try {
            if ("comment".equals(action)) {
                int postId = Integer.parseInt(req.getParameter("postId"));
                ForumCommentDTO comment = new ForumCommentDTO();
                comment.setPostId(postId);
                comment.setAuthorId(user.getId());
                comment.setBody(req.getParameter("body"));
                forumDAO.saveComment(comment);
                resp.sendRedirect(req.getContextPath() + "/forum?action=post&id=" + postId);

            } else if ("deletePost".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ForumPostDTO post = forumDAO.findPostById(id);
                if (post != null && (post.getAuthorId() == user.getId() || "ADMIN".equals(user.getRole()))) {
                    forumDAO.deletePost(id);
                }
                resp.sendRedirect(req.getContextPath() + "/forum");

            } else if ("deleteComment".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                int postId = Integer.parseInt(req.getParameter("postId"));
                forumDAO.deleteComment(id);
                resp.sendRedirect(req.getContextPath() + "/forum?action=post&id=" + postId);

            } else {
                // New post
                ForumPostDTO post = new ForumPostDTO();
                post.setAuthorId(user.getId());
                post.setTitle(req.getParameter("title"));
                post.setBody(req.getParameter("body"));
                String courseParam = req.getParameter("courseId");
                if (courseParam != null && !courseParam.isBlank()) {
                    post.setCourseId(Integer.parseInt(courseParam));
                }
                forumDAO.savePost(post);
                resp.sendRedirect(req.getContextPath() + "/forum?action=post&id=" + post.getId());
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}
