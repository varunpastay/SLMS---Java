package com.slms.servlet.dashboard;

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

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private SubmissionDAO submissionDAO;
    private NotificationDAO notificationDAO;
    private LeaderboardDAO leaderboardDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        enrollmentDAO  = new EnrollmentDAOImpl();
        courseDAO      = new CourseDAOImpl();
        submissionDAO  = new SubmissionDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        leaderboardDAO = new LeaderboardDAOImpl();
        userDAO        = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            String role = user.getRole();

            if ("STUDENT".equals(role)) {
                buildStudentDashboard(req, user);
                req.getRequestDispatcher("/views/dashboard/studentDashboard.jsp").forward(req, resp);

            } else if ("TEACHER".equals(role)) {
                buildTeacherDashboard(req, user);
                req.getRequestDispatcher("/views/dashboard/teacherDashboard.jsp").forward(req, resp);

            } else if ("ADMIN".equals(role)) {
                buildAdminDashboard(req);
                req.getRequestDispatcher("/views/dashboard/adminDashboard.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void buildStudentDashboard(HttpServletRequest req, UserDTO user) throws Exception {
        List<EnrollmentDTO> enrollments = enrollmentDAO.findByStudent(user.getId());
        List<NotificationDTO> notifications = notificationDAO.findByUser(user.getId());
        List<LeaderboardEntryDTO> leaderboard = leaderboardDAO.getLeaderboard(10);
        int unreadNotifications = notificationDAO.countUnread(user.getId());

        int rank = 1;
        for (LeaderboardEntryDTO e : leaderboard) {
            if (e.getStudentId() == user.getId()) { rank = e.getRank(); break; }
        }

        req.setAttribute("enrollments", enrollments);
        req.setAttribute("notifications", notifications);
        req.setAttribute("leaderboard", leaderboard);
        req.setAttribute("leaderboardRank", rank);
        req.setAttribute("unreadNotifications", unreadNotifications);
    }

    private void buildTeacherDashboard(HttpServletRequest req, UserDTO user) throws Exception {
        List<CourseDTO> courses = courseDAO.findByTeacher(user.getId());
        int totalEnrollments = 0;
        for (CourseDTO c : courses) totalEnrollments += enrollmentDAO.countByCourse(c.getId());
        int pendingGrades = submissionDAO.countUngradedByTeacher(user.getId());
        int unreadNotifications = notificationDAO.countUnread(user.getId());

        req.setAttribute("courses", courses);
        req.setAttribute("totalEnrollments", totalEnrollments);
        req.setAttribute("pendingGrades", pendingGrades);
        req.setAttribute("unreadNotifications", unreadNotifications);
    }

    private void buildAdminDashboard(HttpServletRequest req) throws Exception {
        int totalUsers = userDAO.countAll();
        int totalCourses = courseDAO.countAll();
        int totalEnrollments = enrollmentDAO.countAll();
        List<UserDTO> allUsers = userDAO.findAll();

        long totalStudents = allUsers.stream().filter(u -> "STUDENT".equals(u.getRole())).count();
        long totalTeachers = allUsers.stream().filter(u -> "TEACHER".equals(u.getRole())).count();
        long totalAdmins   = allUsers.stream().filter(u -> "ADMIN".equals(u.getRole())).count();

        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalCourses", totalCourses);
        req.setAttribute("totalEnrollments", totalEnrollments);
        req.setAttribute("allUsers", allUsers);
        req.setAttribute("totalStudents", totalStudents);
        req.setAttribute("totalTeachers", totalTeachers);
        req.setAttribute("totalAdmins", totalAdmins);
    }
}
