package com.slms.servlet.course;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.servlet.certificate.CertificateServlet;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/course/complete")
public class CourseCompleteServlet extends HttpServlet {

    private EnrollmentDAO enrollmentDAO;
    private CertificateDAO certificateDAO;
    private NotificationDAO notificationDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() {
        enrollmentDAO   = new EnrollmentDAOImpl();
        certificateDAO  = new CertificateDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        courseDAO       = new CourseDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        try {
            int courseId = Integer.parseInt(req.getParameter("courseId"));
            UserDTO student = SessionUtil.getLoggedUser(req);

            if (!enrollmentDAO.isEnrolled(student.getId(), courseId)) {
                resp.sendError(403); return;
            }

            EnrollmentDTO enrollment = enrollmentDAO.findByStudentAndCourse(student.getId(), courseId);
            if (enrollment != null && enrollment.isCompleted()) {
                resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId);
                return;
            }

            enrollmentDAO.markCompleted(student.getId(), courseId);
            CertificateServlet.issueCertificate(certificateDAO, student.getId(), courseId);

            CourseDTO course = courseDAO.findById(courseId);
            NotificationDTO notif = new NotificationDTO();
            notif.setUserId(student.getId());
            notif.setMessage("Congratulations! You completed \"" + course.getTitle() + "\" and earned a certificate.");
            notificationDAO.save(notif);

            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId + "&completed=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
