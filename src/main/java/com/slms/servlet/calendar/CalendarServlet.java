package com.slms.servlet.calendar;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.SessionUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private AssignmentDAO assignmentDAO;
    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private QuizDAO quizDAO;

    @Override
    public void init() {
        assignmentDAO = new AssignmentDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO     = new CourseDAOImpl();
        quizDAO       = new QuizDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        if ("json".equals(req.getParameter("format"))) {
            serveJson(req, resp, user);
            return;
        }

        req.getRequestDispatcher("/views/calendar/calendar.jsp").forward(req, resp);
    }

    private void serveJson(HttpServletRequest req, HttpServletResponse resp, UserDTO user) throws IOException {
        List<Map<String, Object>> events = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        try {
            List<AssignmentDTO> assignments = new ArrayList<>();
            List<QuizDTO> quizzes = new ArrayList<>();

            if ("STUDENT".equals(user.getRole())) {
                for (EnrollmentDTO e : enrollmentDAO.findByStudent(user.getId())) {
                    assignments.addAll(assignmentDAO.findByCourse(e.getCourseId()));
                    quizzes.addAll(quizDAO.findQuizzesByCourse(e.getCourseId()));
                }
            } else {
                List<CourseDTO> courses = "ADMIN".equals(user.getRole())
                        ? courseDAO.findAll()
                        : courseDAO.findByTeacher(user.getId());
                for (CourseDTO c : courses) {
                    assignments.addAll(assignmentDAO.findByCourse(c.getId()));
                    quizzes.addAll(quizDAO.findQuizzesByCourse(c.getId()));
                }
            }

            for (AssignmentDTO a : assignments) {
                if (a.getDueDate() != null) {
                    Map<String, Object> ev = new HashMap<>();
                    ev.put("title", "Due: " + a.getTitle());
                    ev.put("start", sdf.format(a.getDueDate()));
                    ev.put("color", "#dc3545");
                    ev.put("url", req.getContextPath() + "/course/detail?id=" + a.getCourseId());
                    events.add(ev);
                }
            }

            // Quizzes have no due date — show as created events
            for (QuizDTO q : quizzes) {
                if (q.getCreatedAt() != null) {
                    Map<String, Object> ev = new HashMap<>();
                    ev.put("title", "Quiz: " + q.getTitle());
                    ev.put("start", sdf.format(q.getCreatedAt()));
                    ev.put("color", "#0d6efd");
                    ev.put("url", req.getContextPath() + "/course/detail?id=" + q.getCourseId());
                    events.add(ev);
                }
            }
        } catch (Exception e) {
            System.err.println("[CalendarServlet] Error loading events: " + e.getMessage());
        }

        resp.setContentType("application/json;charset=UTF-8");
        new ObjectMapper().writeValue(resp.getWriter(), events);
    }
}
