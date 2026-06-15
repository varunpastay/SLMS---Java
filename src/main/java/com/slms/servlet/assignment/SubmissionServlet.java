package com.slms.servlet.assignment;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.EmailUtil;
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
import java.math.BigDecimal;
import java.util.List;
import java.util.Properties;

@WebServlet("/submission")
@MultipartConfig(maxFileSize = 20 * 1024 * 1024)
public class SubmissionServlet extends HttpServlet {

    private SubmissionDAO submissionDAO;
    private AssignmentDAO assignmentDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;
    private String uploadDir;

    @Override
    public void init() throws ServletException {
        submissionDAO   = new SubmissionDAOImpl();
        assignmentDAO   = new AssignmentDAOImpl();
        userDAO         = new UserDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties p = new Properties(); p.load(in);
            uploadDir = p.getProperty("upload.dir", "C:/slms_uploads");
        } catch (IOException e) { throw new ServletException(e); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("view".equals(action)) {
                // Teacher views all submissions for an assignment
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
                List<SubmissionDTO> submissions = submissionDAO.findByAssignment(assignmentId);
                req.setAttribute("submissions", submissions);
                req.setAttribute("assignment", assignmentDAO.findById(assignmentId));
                req.getRequestDispatcher("/views/assignment/submissionList.jsp").forward(req, resp);

            } else if ("grade".equals(action)) {
                // Grade form
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("submission", submissionDAO.findById(id));
                req.getRequestDispatcher("/views/assignment/gradeForm.jsp").forward(req, resp);

            } else {
                // Student views their own submission
                UserDTO student = SessionUtil.getLoggedUser(req);
                int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
                SubmissionDTO sub = submissionDAO.findByAssignmentAndStudent(assignmentId, student.getId());
                req.setAttribute("submission", sub);
                req.setAttribute("assignment", assignmentDAO.findById(assignmentId));
                req.getRequestDispatcher("/views/assignment/submitAssignment.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("grade".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int id = Integer.parseInt(req.getParameter("id"));
                BigDecimal marks = new BigDecimal(req.getParameter("marks"));
                String feedback = req.getParameter("feedback");
                submissionDAO.grade(id, marks, feedback);

                SubmissionDTO sub = submissionDAO.findById(id);
                UserDTO student   = userDAO.findById(sub.getStudentId());
                AssignmentDTO a   = assignmentDAO.findById(sub.getAssignmentId());

                NotificationDTO notif = new NotificationDTO();
                notif.setUserId(student.getId());
                notif.setMessage("Your assignment \"" + a.getTitle() + "\" has been graded. Marks: " + marks);
                notificationDAO.save(notif);

                new Thread(() -> EmailUtil.sendAssignmentGraded(
                    student.getEmail(), student.getFullName(), a.getTitle(),
                    marks.toPlainString(), feedback)).start();

                resp.sendRedirect(req.getContextPath() + "/submission?action=view&assignmentId=" + sub.getAssignmentId());

            } else {
                // Student submits
                if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
                UserDTO student  = SessionUtil.getLoggedUser(req);
                int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));

                // Check for existing submission
                SubmissionDTO existing = submissionDAO.findByAssignmentAndStudent(assignmentId, student.getId());
                if (existing != null) {
                    resp.sendRedirect(req.getContextPath() + "/submission?assignmentId=" + assignmentId + "&error=already");
                    return;
                }

                String filePath = FileUploadUtil.saveFile(req, "submissionFile", "submissions", uploadDir);
                SubmissionDTO sub = new SubmissionDTO();
                sub.setAssignmentId(assignmentId);
                sub.setStudentId(student.getId());
                sub.setFilePath(filePath);
                submissionDAO.save(sub);

                resp.sendRedirect(req.getContextPath() + "/submission?assignmentId=" + assignmentId + "&success=1");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}
