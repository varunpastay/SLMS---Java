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

@WebServlet("/course/edit")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class CourseEditServlet extends HttpServlet {

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
            int id = Integer.parseInt(req.getParameter("id"));
            CourseDTO course = courseDAO.findById(id);
            if (course == null) { resp.sendError(404); return; }

            UserDTO user = SessionUtil.getLoggedUser(req);
            if ("TEACHER".equals(user.getRole()) && course.getTeacherId() != user.getId()) {
                resp.sendError(403); return;
            }
            req.setAttribute("course", course);
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/views/course/courseForm.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            CourseDTO course = courseDAO.findById(id);
            if (course == null) { resp.sendError(404); return; }
            if ("TEACHER".equals(user.getRole()) && course.getTeacherId() != user.getId()) {
                resp.sendError(403); return;
            }

            course.setTitle(req.getParameter("title"));
            course.setDescription(req.getParameter("description"));
            String catStr = req.getParameter("categoryId");
            if (catStr != null && !catStr.isBlank()) course.setCategoryId(Integer.parseInt(catStr));
            course.setYoutubeUrl(req.getParameter("youtubeUrl"));
            course.setPublished("on".equals(req.getParameter("isPublished")));

            String newThumb = FileUploadUtil.saveFile(req, "thumbnail", "thumbnails", uploadDir);
            if (newThumb != null) course.setThumbnail(newThumb);

            courseDAO.update(course);
            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + id);
        } catch (Exception e) { throw new ServletException(e); }
    }
}
