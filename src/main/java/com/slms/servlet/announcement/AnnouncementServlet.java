package com.slms.servlet.announcement;

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

@WebServlet("/announcement")
public class AnnouncementServlet extends HttpServlet {

    private AnnouncementDAO announcementDAO;
    private NotificationDAO notificationDAO;
    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() {
        announcementDAO = new AnnouncementDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        enrollmentDAO   = new EnrollmentDAOImpl();
        courseDAO       = new CourseDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
        UserDTO author = SessionUtil.getLoggedUser(req);
        String action  = req.getParameter("action");

        try {
            if ("delete".equals(action)) {
                announcementDAO.delete(Integer.parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + req.getParameter("courseId"));
                return;
            }

            int courseId = Integer.parseInt(req.getParameter("courseId"));
            AnnouncementDTO a = new AnnouncementDTO();
            a.setCourseId(courseId);
            a.setAuthorId(author.getId());
            a.setTitle(req.getParameter("title"));
            a.setBody(req.getParameter("body"));
            announcementDAO.save(a);

            CourseDTO course = courseDAO.findById(courseId);
            List<EnrollmentDTO> enrollments = enrollmentDAO.findByCourse(courseId);
            for (EnrollmentDTO e : enrollments) {
                NotificationDTO notif = new NotificationDTO();
                notif.setUserId(e.getStudentId());
                notif.setMessage("New announcement in \"" + course.getTitle() + "\": " + a.getTitle());
                notificationDAO.save(notif);
            }

            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId + "&announced=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
