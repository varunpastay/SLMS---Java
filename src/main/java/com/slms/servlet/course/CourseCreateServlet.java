package com.slms.servlet.course;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.FileUploadUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

@WebServlet("/course/create")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class CourseCreateServlet extends HttpServlet {

    private CourseDAO courseDAO;
    private CategoryDAO categoryDAO;
    private String uploadDir;

    @Override
    public void init() throws ServletException {
        courseDAO   = new CourseDAOImpl();
        categoryDAO = new CategoryDAOImpl();
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties p = new Properties(); p.load(in);
            uploadDir = p.getProperty("upload.dir", "C:/slms_uploads");
        } catch (IOException e) { throw new ServletException(e); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
        try {
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/views/course/courseForm.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null || (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) {
            resp.sendError(403); return;
        }
        try {
            String title       = req.getParameter("title");
            String description = req.getParameter("description");
            String catStr      = req.getParameter("categoryId");
            String youtubeUrl  = req.getParameter("youtubeUrl");
            boolean published  = "on".equals(req.getParameter("isPublished"));

            String thumbnail = FileUploadUtil.saveFile(req, "thumbnail", "thumbnails", uploadDir);

            CourseDTO course = new CourseDTO();
            course.setTitle(title);
            course.setDescription(description);
            course.setTeacherId(user.getId());
            if (catStr != null && !catStr.isBlank()) course.setCategoryId(Integer.parseInt(catStr));
            course.setYoutubeUrl(youtubeUrl);
            course.setPublished(published);
            course.setThumbnail(thumbnail);

            courseDAO.save(course);
            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + course.getId());
        } catch (Exception e) {
            req.setAttribute("error", "Failed to create course: " + e.getMessage());
            try { req.setAttribute("categories", categoryDAO.findAll()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/views/course/courseForm.jsp").forward(req, resp);
        }
    }
}
