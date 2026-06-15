package com.slms.servlet.course;

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

@WebServlet("/course/detail")
public class CourseDetailServlet extends HttpServlet {

    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private CourseMaterialDAO materialDAO;
    private AssignmentDAO assignmentDAO;
    private QuizDAO quizDAO;
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() {
        courseDAO     = new CourseDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO   = new CourseMaterialDAOImpl();
        assignmentDAO = new AssignmentDAOImpl();
        quizDAO       = new QuizDAOImpl();
        feedbackDAO   = new FeedbackDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        try {
            int courseId = Integer.parseInt(req.getParameter("id"));
            UserDTO user = SessionUtil.getLoggedUser(req);

            CourseDTO course = courseDAO.findById(courseId);
            if (course == null) { resp.sendError(404); return; }

            boolean enrolled = enrollmentDAO.isEnrolled(user.getId(), courseId);
            List<CourseMaterialDTO> materials = materialDAO.findByCourse(courseId);
            List<AssignmentDTO> assignments   = assignmentDAO.findByCourse(courseId);
            List<QuizDTO> quizzes             = quizDAO.findQuizzesByCourse(courseId);
            List<FeedbackDTO> feedbacks        = feedbackDAO.findByCourse(courseId);

            FeedbackDTO myFeedback = null;
            if ("STUDENT".equals(user.getRole())) {
                myFeedback = feedbackDAO.findByStudentAndCourse(user.getId(), courseId);
            }

            req.setAttribute("course", course);
            req.setAttribute("enrolled", enrolled);
            req.setAttribute("materials", materials);
            req.setAttribute("assignments", assignments);
            req.setAttribute("quizzes", quizzes);
            req.setAttribute("feedbacks", feedbacks);
            req.setAttribute("myFeedback", myFeedback);
            req.getRequestDispatcher("/views/course/courseDetail.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
