package com.slms.servlet.gradebook;

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

@WebServlet("/gradebook")
public class GradeBookServlet extends HttpServlet {

    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private AssignmentDAO assignmentDAO;
    private SubmissionDAO submissionDAO;
    private QuizDAO quizDAO;

    @Override
    public void init() {
        courseDAO     = new CourseDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        assignmentDAO = new AssignmentDAOImpl();
        submissionDAO = new SubmissionDAOImpl();
        quizDAO       = new QuizDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            if ("STUDENT".equals(user.getRole())) {
                // Student: see their own grades across all enrolled courses
                List<EnrollmentDTO> enrollments = enrollmentDAO.findByStudent(user.getId());
                req.setAttribute("enrollments", enrollments);

                // For each enrollment, load submissions + quiz attempts
                req.setAttribute("submissionDAO", submissionDAO);
                req.setAttribute("assignmentDAO", assignmentDAO);
                req.setAttribute("quizDAO", quizDAO);

                // We'll pass all submissions for this student
                List<SubmissionDTO> submissions = submissionDAO.findByStudent(user.getId());
                req.setAttribute("submissions", submissions);

                List<QuizAttemptDTO> attempts = quizDAO.findAttemptsByStudent(user.getId());
                req.setAttribute("attempts", attempts);

                req.getRequestDispatcher("/views/gradebook/studentGrades.jsp").forward(req, resp);

            } else if ("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
                // Teacher: pick a course first, then see grade grid
                String courseIdStr = req.getParameter("courseId");
                List<CourseDTO> courses = "ADMIN".equals(user.getRole())
                        ? courseDAO.findAll()
                        : courseDAO.findByTeacher(user.getId());
                req.setAttribute("courses", courses);

                if (courseIdStr != null) {
                    int courseId = Integer.parseInt(courseIdStr);
                    CourseDTO course = courseDAO.findById(courseId);
                    req.setAttribute("course", course);

                    List<EnrollmentDTO> enrollments = enrollmentDAO.findByCourse(courseId);
                    req.setAttribute("enrollments", enrollments);

                    List<AssignmentDTO> assignments = assignmentDAO.findByCourse(courseId);
                    req.setAttribute("assignments", assignments);

                    List<QuizDTO> quizzes = quizDAO.findQuizzesByCourse(courseId);
                    req.setAttribute("quizzes", quizzes);

                    // Submissions indexed by studentId -> assignmentId -> submission
                    java.util.Map<Integer, java.util.Map<Integer, SubmissionDTO>> gradeGrid = new java.util.HashMap<>();
                    for (AssignmentDTO a : assignments) {
                        List<SubmissionDTO> subs = submissionDAO.findByAssignment(a.getId());
                        for (SubmissionDTO s : subs) {
                            gradeGrid.computeIfAbsent(s.getStudentId(), k -> new java.util.HashMap<>())
                                     .put(a.getId(), s);
                        }
                    }
                    req.setAttribute("gradeGrid", gradeGrid);

                    // Quiz attempts indexed by studentId -> quizId -> attempt
                    java.util.Map<Integer, java.util.Map<Integer, QuizAttemptDTO>> quizGrid = new java.util.HashMap<>();
                    for (QuizDTO q : quizzes) {
                        List<QuizAttemptDTO> attempts = quizDAO.findAttemptsByQuiz(q.getId());
                        for (QuizAttemptDTO a : attempts) {
                            quizGrid.computeIfAbsent(a.getStudentId(), k -> new java.util.HashMap<>())
                                    .put(q.getId(), a);
                        }
                    }
                    req.setAttribute("quizGrid", quizGrid);
                }
                req.getRequestDispatcher("/views/gradebook/gradeBook.jsp").forward(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
