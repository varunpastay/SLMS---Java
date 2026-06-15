package com.slms.servlet.course;

import com.slms.dao.CourseDAO;
import com.slms.dao.CourseDAOImpl;
import com.slms.dto.CourseDTO;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/course/delete")
public class CourseDeleteServlet extends HttpServlet {

    private CourseDAO courseDAO;

    @Override
    public void init() {
        courseDAO = new CourseDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            UserDTO user = SessionUtil.getLoggedUser(req);
            CourseDTO course = courseDAO.findById(id);
            if (course == null) { resp.sendError(404); return; }
            if ("TEACHER".equals(user.getRole()) && course.getTeacherId() != user.getId()) {
                resp.sendError(403); return;
            }
            courseDAO.delete(id);
            resp.sendRedirect(req.getContextPath() + "/courses");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
