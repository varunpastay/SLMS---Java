package com.slms.servlet.course;

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

@WebServlet("/course/enroll")
public class EnrollServlet extends HttpServlet {

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        enrollmentDAO    = new EnrollmentDAOImpl();
        courseDAO        = new CourseDAOImpl();
        notificationDAO  = new NotificationDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        try {
            int courseId = Integer.parseInt(req.getParameter("courseId"));
            UserDTO student = SessionUtil.getLoggedUser(req);

            if (enrollmentDAO.isEnrolled(student.getId(), courseId)) {
                resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId);
                return;
            }

            CourseDTO course = courseDAO.findById(courseId);
            if (course == null || !course.isPublished()) { resp.sendError(404); return; }

            EnrollmentDTO enrollment = new EnrollmentDTO();
            enrollment.setStudentId(student.getId());
            enrollment.setCourseId(courseId);
            enrollmentDAO.save(enrollment);

            // Notification
            NotificationDTO notif = new NotificationDTO();
            notif.setUserId(student.getId());
            notif.setMessage("You have successfully enrolled in \"" + course.getTitle() + "\".");
            notificationDAO.save(notif);

            // Email (async)
            String name = student.getFullName();
            new Thread(() -> EmailUtil.sendEnrollmentConfirmation(student.getEmail(), name, course.getTitle())).start();

            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId + "&enrolled=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
