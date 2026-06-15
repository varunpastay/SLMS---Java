package com.slms.servlet.feedback;

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

@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private FeedbackDAO feedbackDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() {
        feedbackDAO = new FeedbackDAOImpl();
        courseDAO   = new CourseDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        UserDTO user = SessionUtil.getLoggedUser(req);

        try {
            if ("TEACHER".equals(user.getRole())) {
                List<FeedbackDTO> feedbacks = feedbackDAO.findByTeacher(user.getId());
                double avgRating = feedbackDAO.avgRatingForTeacher(user.getId());
                req.setAttribute("feedbacks", feedbacks);
                req.setAttribute("avgRating", avgRating);
                req.getRequestDispatcher("/views/feedback/teacherFeedback.jsp").forward(req, resp);
            } else {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                CourseDTO course = courseDAO.findById(courseId);
                FeedbackDTO existing = feedbackDAO.findByStudentAndCourse(user.getId(), courseId);
                req.setAttribute("course", course);
                req.setAttribute("existingFeedback", existing);
                req.getRequestDispatcher("/views/feedback/feedbackForm.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO student = SessionUtil.getLoggedUser(req);

        try {
            int courseId  = Integer.parseInt(req.getParameter("courseId"));
            int teacherId = Integer.parseInt(req.getParameter("teacherId"));
            int rating    = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");

            FeedbackDTO existing = feedbackDAO.findByStudentAndCourse(student.getId(), courseId);
            if (existing != null) {
                resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId + "&feedbackError=duplicate");
                return;
            }

            FeedbackDTO feedback = new FeedbackDTO();
            feedback.setStudentId(student.getId());
            feedback.setTeacherId(teacherId);
            feedback.setCourseId(courseId);
            feedback.setRating(Math.max(1, Math.min(5, rating)));
            feedback.setComment(comment);
            feedbackDAO.save(feedback);

            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId + "&feedback=1");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
