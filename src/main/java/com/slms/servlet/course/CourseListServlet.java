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

@WebServlet("/courses")
public class CourseListServlet extends HttpServlet {

    private CourseDAO courseDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        courseDAO    = new CourseDAOImpl();
        categoryDAO  = new CategoryDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        try {
            String keyword = req.getParameter("q");
            String catParam = req.getParameter("category");

            List<CourseDTO> courses;
            if (keyword != null && !keyword.isBlank()) {
                courses = courseDAO.search(keyword.trim());
            } else if (catParam != null && !catParam.isBlank()) {
                courses = courseDAO.findByCategory(Integer.parseInt(catParam));
            } else {
                UserDTO user = SessionUtil.getLoggedUser(req);
                if ("TEACHER".equals(user.getRole())) {
                    courses = courseDAO.findByTeacher(user.getId());
                } else if ("ADMIN".equals(user.getRole())) {
                    courses = courseDAO.findAll();
                } else {
                    courses = courseDAO.findAllPublished();
                }
            }

            List<CategoryDTO> categories = categoryDAO.findAll();
            req.setAttribute("courses", courses);
            req.setAttribute("categories", categories);
            req.getRequestDispatcher("/views/course/courseList.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
