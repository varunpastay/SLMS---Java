package com.slms.servlet.certificate;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
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

import java.awt.Color;
import java.io.IOException;
import java.text.SimpleDateFormat;
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

        if ("/download".equals(pathInfo)) {
            if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
            UserDTO student = SessionUtil.getLoggedUser(req);
            try {
                int certId = Integer.parseInt(req.getParameter("id"));
                CertificateDTO cert = certificateDAO.findById(certId);
                if (cert == null || cert.getStudentId() != student.getId()) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                generatePdf(resp, cert);
            } catch (Exception e) {
                throw new ServletException(e);
            }
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

    private void generatePdf(HttpServletResponse resp, CertificateDTO cert) throws Exception {
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"certificate-" + cert.getCertificateCode() + ".pdf\"");

        Document doc = new Document(PageSize.A4.rotate());
        PdfWriter writer = PdfWriter.getInstance(doc, resp.getOutputStream());
        doc.open();

        PdfContentByte cb = writer.getDirectContent();

        // Gold border
        cb.setColorStroke(new Color(218, 165, 32));
        cb.setLineWidth(8f);
        cb.rectangle(30, 30, doc.getPageSize().getWidth() - 60, doc.getPageSize().getHeight() - 60);
        cb.stroke();

        // Inner border
        cb.setColorStroke(new Color(180, 130, 20));
        cb.setLineWidth(2f);
        cb.rectangle(40, 40, doc.getPageSize().getWidth() - 80, doc.getPageSize().getHeight() - 80);
        cb.stroke();

        Font titleFont  = new Font(Font.HELVETICA, 36, Font.BOLD, new Color(10, 50, 100));
        Font headerFont = new Font(Font.HELVETICA, 16, Font.ITALIC, Color.DARK_GRAY);
        Font nameFont   = new Font(Font.HELVETICA, 28, Font.BOLD, new Color(10, 50, 100));
        Font bodyFont   = new Font(Font.HELVETICA, 14, Font.NORMAL, Color.DARK_GRAY);
        Font codeFont   = new Font(Font.HELVETICA, 10, Font.ITALIC, Color.GRAY);

        Paragraph spacer = new Paragraph("\n");

        Paragraph title = new Paragraph("Certificate of Completion", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(spacer);
        doc.add(title);

        Paragraph sub = new Paragraph("This is to certify that", headerFont);
        sub.setAlignment(Element.ALIGN_CENTER);
        sub.setSpacingBefore(20);
        doc.add(sub);

        Paragraph name = new Paragraph(cert.getStudentName(), nameFont);
        name.setAlignment(Element.ALIGN_CENTER);
        name.setSpacingBefore(10);
        doc.add(name);

        Paragraph body = new Paragraph(
                "has successfully completed the course\n\n" + cert.getCourseTitle(), bodyFont);
        body.setAlignment(Element.ALIGN_CENTER);
        body.setSpacingBefore(16);
        doc.add(body);

        if (cert.getTeacherName() != null) {
            Paragraph teacher = new Paragraph("Instructor: " + cert.getTeacherName(), bodyFont);
            teacher.setAlignment(Element.ALIGN_CENTER);
            teacher.setSpacingBefore(12);
            doc.add(teacher);
        }

        String dateStr = cert.getIssuedAt() != null
                ? new SimpleDateFormat("MMMM dd, yyyy").format(cert.getIssuedAt())
                : "";
        Paragraph date = new Paragraph("Issued on: " + dateStr, bodyFont);
        date.setAlignment(Element.ALIGN_CENTER);
        date.setSpacingBefore(12);
        doc.add(date);

        Paragraph code = new Paragraph("Certificate Code: " + cert.getCertificateCode(), codeFont);
        code.setAlignment(Element.ALIGN_CENTER);
        code.setSpacingBefore(20);
        doc.add(code);

        doc.close();
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
