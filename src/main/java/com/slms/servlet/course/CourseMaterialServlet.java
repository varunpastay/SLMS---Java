package com.slms.servlet.course;

import com.slms.dao.CourseMaterialDAO;
import com.slms.dao.CourseMaterialDAOImpl;
import com.slms.dao.CourseDAO;
import com.slms.dao.CourseDAOImpl;
import com.slms.dto.CourseMaterialDTO;
import com.slms.dto.CourseDTO;
import com.slms.dto.UserDTO;
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

@WebServlet("/material/*")
@MultipartConfig(maxFileSize = 50 * 1024 * 1024)
public class CourseMaterialServlet extends HttpServlet {

    private CourseMaterialDAO materialDAO;
    private CourseDAO courseDAO;
    private String uploadDir;

    @Override
    public void init() throws ServletException {
        materialDAO = new CourseMaterialDAOImpl();
        courseDAO   = new CourseDAOImpl();
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties p = new Properties(); p.load(in);
            uploadDir = p.getProperty("upload.dir", "C:/slms_uploads");
        } catch (IOException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        String pathInfo = req.getPathInfo();

        try {
            if ("/delete".equals(pathInfo)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CourseMaterialDTO mat = materialDAO.findById(id);
                if (mat != null) {
                    CourseDTO course = courseDAO.findById(mat.getCourseId());
                    if ("ADMIN".equals(user.getRole()) || course.getTeacherId() == user.getId()) {
                        FileUploadUtil.deleteFile(mat.getFilePath(), uploadDir);
                        materialDAO.delete(id);
                    }
                    resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + mat.getCourseId());
                } else {
                    resp.sendError(404);
                }
                return;
            }

            // Add material
            int courseId = Integer.parseInt(req.getParameter("courseId"));
            CourseDTO course = courseDAO.findById(courseId);
            if (course == null || (!"ADMIN".equals(user.getRole()) && course.getTeacherId() != user.getId())) {
                resp.sendError(403); return;
            }

            String title = req.getParameter("title");
            String type  = req.getParameter("materialType");
            String filePath = FileUploadUtil.saveFile(req, "materialFile", "materials", uploadDir);

            CourseMaterialDTO mat = new CourseMaterialDTO();
            mat.setCourseId(courseId);
            mat.setTitle(title);
            mat.setMaterialType(type);
            mat.setFilePath(filePath);
            materialDAO.save(mat);

            resp.sendRedirect(req.getContextPath() + "/course/detail?id=" + courseId);
        } catch (Exception e) { throw new ServletException(e); }
    }
}
