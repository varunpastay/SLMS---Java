package com.slms.servlet.assignment;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.EmailUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/assignment")
public class AssignmentServlet extends HttpServlet {

    private AssignmentDAO assignmentDAO;
    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private NotificationDAO notificationDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        assignmentDAO   = new AssignmentDAOImpl();
        courseDAO       = new CourseDAOImpl();
        enrollmentDAO   = new EnrollmentDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        userDAO         = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                req.setAttribute("courseId", courseId);
                req.getRequestDispatcher("/views/assignment/assignmentForm.jsp").forward(req, resp);

            } else if ("edit".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("assignment", assignmentDAO.findById(id));
                req.getRequestDispatcher("/views/assignment/assignmentForm.jsp").forward(req, resp);

            } else {
                // List by course
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                List<AssignmentDTO> assignments = assignmentDAO.findByCourse(courseId);
                CourseDTO course = courseDAO.findById(courseId);
                req.setAttribute("assignments", assignments);
                req.setAttribute("course", course);
                req.getRequestDispatcher("/views/assignment/assignmentList.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
        String action = req.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                AssignmentDTO a = assignmentDAO.findById(id);
                assignmentDAO.delete(id);
                resp.sendRedirect(req.getContextPath() + "/assignment?courseId=" + a.getCourseId());
                return;
            }

            String title       = req.getParameter("title");
            String description = req.getParameter("description");
            String dueDateStr  = req.getParameter("dueDate");
            int maxMarks       = Integer.parseInt(req.getParameter("maxMarks"));
            int courseId       = Integer.parseInt(req.getParameter("courseId"));

            AssignmentDTO assignment = new AssignmentDTO();
            assignment.setTitle(title);
            assignment.setDescription(description);
            assignment.setMaxMarks(maxMarks);
            assignment.setCourseId(courseId);
            if (dueDateStr != null && !dueDateStr.isBlank()) {
                java.time.LocalDateTime ldt = java.time.LocalDateTime.parse(dueDateStr, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                assignment.setDueDate(java.sql.Timestamp.valueOf(ldt));
            }

            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isBlank()) {
                assignment.setId(Integer.parseInt(idStr));
                assignmentDAO.update(assignment);
            } else {
                assignmentDAO.save(assignment);

                // Notify enrolled students
                CourseDTO course = courseDAO.findById(courseId);
                List<EnrollmentDTO> enrollments = enrollmentDAO.findByCourse(courseId);
                for (EnrollmentDTO e : enrollments) {
                    UserDTO student = userDAO.findById(e.getStudentId());
                    if (student == null) continue;

                    NotificationDTO notif = new NotificationDTO();
                    notif.setUserId(student.getId());
                    notif.setMessage("New assignment posted in \"" + course.getTitle() + "\": " + title);
                    notificationDAO.save(notif);

                    new Thread(() -> EmailUtil.sendNewAssignmentNotice(
                        student.getEmail(), student.getFullName(), course.getTitle(), title)).start();
                }
            }

            resp.sendRedirect(req.getContextPath() + "/assignment?courseId=" + courseId);
        } catch (Exception e) { throw new ServletException(e); }
    }
}
