package com.slms.servlet.certificate;

import com.slms.dao.CertificateDAO;
import com.slms.dao.CertificateDAOImpl;
import com.slms.dto.CertificateDTO;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/certificate/*")
public class CertificateServlet extends HttpServlet {

    private CertificateDAO certificateDAO;

    @Override
    public void init() {
        certificateDAO = new CertificateDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        if ("/verify".equals(pathInfo)) {
            // Public certificate verification page
            String code = req.getParameter("code");
            if (code != null && !code.isBlank()) {
                try {
                    CertificateDTO cert = certificateDAO.findByCode(code.trim());
                    req.setAttribute("certificate", cert);
                } catch (Exception e) {
                    req.setAttribute("error", "Lookup failed.");
                }
            }
            req.getRequestDispatcher("/views/certificate/verify.jsp").forward(req, resp);
            return;
        }

        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO student = SessionUtil.getLoggedUser(req);

        try {
            List<CertificateDTO> certs = certificateDAO.findByStudent(student.getId());
            req.setAttribute("certificates", certs);
            req.getRequestDispatcher("/views/certificate/myCertificates.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    /** Called internally after course completion to issue a certificate. */
    public static void issueCertificate(CertificateDAO dao, int studentId, int courseId) {
        try {
            if (!dao.exists(studentId, courseId)) {
                CertificateDTO cert = new CertificateDTO();
                cert.setStudentId(studentId);
                cert.setCourseId(courseId);
                cert.setCertificateCode(UUID.randomUUID().toString().replace("-", "").toUpperCase());
                dao.save(cert);
            }
        } catch (Exception e) {
            System.err.println("[CertificateServlet] Failed to issue certificate: " + e.getMessage());
        }
    }
}
