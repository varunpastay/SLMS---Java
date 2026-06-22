package com.slms.servlet.omr;

import com.slms.config.DBConfig;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

@WebServlet("/omr")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 12 * 1024 * 1024)
public class OMRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        try {
            if ("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
                if ("create".equals(action)) {
                    loadTeacherCourses(req, user.getId());
                    req.getRequestDispatcher("/views/omr/omrCreate.jsp").forward(req, resp);
                } else if ("view".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    loadEvaluationDetails(req, id, user.getId());
                    req.getRequestDispatcher("/views/omr/omrView.jsp").forward(req, resp);
                } else if ("export".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    exportCSV(resp, id, user.getId());
                } else if ("delete".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    deleteEvaluation(id, user.getId());
                    resp.sendRedirect(req.getContextPath() + "/omr?deleted=1");
                } else {
                    loadTeacherEvaluations(req, user.getId());
                    req.getRequestDispatcher("/views/omr/omrList.jsp").forward(req, resp);
                }
            } else {
                // Student
                loadStudentResults(req, user.getId());
                req.getRequestDispatcher("/views/omr/omrStudentResults.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDTO user = SessionUtil.getLoggedUser(req);
        if (user == null || (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        try {
            processUpload(req, resp, user);
        } catch (Exception e) {
            req.setAttribute("error", "Processing failed: " + e.getMessage());
            try { loadTeacherCourses(req, user.getId()); } catch (SQLException ignored) {}
            req.getRequestDispatcher("/views/omr/omrCreate.jsp").forward(req, resp);
        }
    }

    // ── DB loaders ────────────────────────────────────────────────────────────

    private void loadTeacherCourses(HttpServletRequest req, int teacherId) throws SQLException {
        List<Map<String, Object>> courses = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT id, title FROM courses WHERE teacher_id=? ORDER BY title")) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> c = new LinkedHashMap<>();
                c.put("id",    rs.getInt("id"));
                c.put("title", rs.getString("title"));
                courses.add(c);
            }
        }
        req.setAttribute("courses", courses);
    }

    private void loadTeacherEvaluations(HttpServletRequest req, int teacherId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT e.id, e.title, e.total_questions, e.marks_per_correct, e.negative_marks, " +
                "       e.total_marks, e.created_at, c.title AS course_title, " +
                "       COUNT(r.id) AS student_count, AVG(r.marks_obtained) AS avg_marks, " +
                "       MAX(r.marks_obtained) AS top_marks " +
                "FROM omr_evaluations e " +
                "LEFT JOIN courses c ON e.course_id = c.id " +
                "LEFT JOIN omr_results r ON r.evaluation_id = e.id " +
                "WHERE e.teacher_id = ? " +
                "GROUP BY e.id ORDER BY e.created_at DESC")) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> ev = new LinkedHashMap<>();
                ev.put("id",              rs.getInt("id"));
                ev.put("title",           rs.getString("title"));
                ev.put("courseTitle",     rs.getString("course_title"));
                ev.put("totalQuestions",  rs.getInt("total_questions"));
                ev.put("totalMarks",      rs.getBigDecimal("total_marks"));
                ev.put("studentCount",    rs.getInt("student_count"));
                ev.put("avgMarks",        rs.getBigDecimal("avg_marks"));
                ev.put("topMarks",        rs.getBigDecimal("top_marks"));
                ev.put("createdAt",       rs.getString("created_at"));
                list.add(ev);
            }
        }
        req.setAttribute("evaluations", list);
    }

    private void loadEvaluationDetails(HttpServletRequest req, int evalId, int teacherId)
            throws SQLException {
        try (Connection con = DBConfig.getConnection()) {
            Map<String, Object> eval = new LinkedHashMap<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT e.*, c.title AS course_title FROM omr_evaluations e " +
                    "LEFT JOIN courses c ON e.course_id = c.id " +
                    "WHERE e.id = ? AND e.teacher_id = ?")) {
                ps.setInt(1, evalId); ps.setInt(2, teacherId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) throw new RuntimeException("Evaluation not found");
                eval.put("id",              rs.getInt("id"));
                eval.put("title",           rs.getString("title"));
                eval.put("courseTitle",     rs.getString("course_title"));
                eval.put("totalQuestions",  rs.getInt("total_questions"));
                eval.put("marksPerCorrect", rs.getBigDecimal("marks_per_correct"));
                eval.put("negativeMarks",   rs.getBigDecimal("negative_marks"));
                eval.put("totalMarks",      rs.getBigDecimal("total_marks"));
                eval.put("answerKey",       rs.getString("answer_key"));
                eval.put("createdAt",       rs.getString("created_at"));
            }

            List<Map<String, Object>> results = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT r.* FROM omr_results r WHERE r.evaluation_id = ? " +
                    "ORDER BY r.marks_obtained DESC, r.correct_count DESC")) {
                ps.setInt(1, evalId);
                ResultSet rs = ps.executeQuery();
                int rank = 1;
                while (rs.next()) {
                    Map<String, Object> r = new LinkedHashMap<>();
                    r.put("rank",              rank++);
                    r.put("studentIdentifier", rs.getString("student_identifier"));
                    r.put("studentName",       rs.getString("student_name"));
                    r.put("responses",         rs.getString("responses"));
                    r.put("correctCount",      rs.getInt("correct_count"));
                    r.put("wrongCount",        rs.getInt("wrong_count"));
                    r.put("unattempted",       rs.getInt("unattempted_count"));
                    r.put("marksObtained",     rs.getBigDecimal("marks_obtained"));
                    r.put("percentage",        rs.getBigDecimal("percentage"));
                    r.put("linked",            rs.getInt("student_id") != 0);
                    results.add(r);
                }
            }
            req.setAttribute("evaluation", eval);
            req.setAttribute("results",    results);
        }
    }

    private void loadStudentResults(HttpServletRequest req, int studentId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT r.correct_count, r.wrong_count, r.unattempted_count, " +
                "       r.marks_obtained, r.percentage, r.responses, " +
                "       e.id AS eval_id, e.title, e.total_questions, e.total_marks, " +
                "       e.answer_key, e.created_at, " +
                "       c.title AS course_title, " +
                "       u.first_name, u.last_name " +
                "FROM omr_results r " +
                "JOIN omr_evaluations e ON r.evaluation_id = e.id " +
                "LEFT JOIN courses c ON e.course_id = c.id " +
                "JOIN users u ON e.teacher_id = u.id " +
                "WHERE r.student_id = ? ORDER BY e.created_at DESC")) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> r = new LinkedHashMap<>();
                r.put("evalId",         rs.getInt("eval_id"));
                r.put("title",          rs.getString("title"));
                r.put("courseTitle",    rs.getString("course_title"));
                r.put("teacherName",    rs.getString("first_name") + " " + rs.getString("last_name"));
                r.put("totalQuestions", rs.getInt("total_questions"));
                r.put("totalMarks",     rs.getBigDecimal("total_marks"));
                r.put("answerKey",      rs.getString("answer_key"));
                r.put("responses",      rs.getString("responses"));
                r.put("correctCount",   rs.getInt("correct_count"));
                r.put("wrongCount",     rs.getInt("wrong_count"));
                r.put("unattempted",    rs.getInt("unattempted_count"));
                r.put("marksObtained",  rs.getBigDecimal("marks_obtained"));
                r.put("percentage",     rs.getBigDecimal("percentage"));
                r.put("createdAt",      rs.getString("created_at"));
                list.add(r);
            }
        }
        req.setAttribute("omrResults", list);
    }

    // ── Core processing ───────────────────────────────────────────────────────

    private void processUpload(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        String title       = req.getParameter("title");
        String answerKeyRaw = req.getParameter("answerKey").trim();
        String mpcStr      = req.getParameter("marksPerCorrect");
        String negStr      = req.getParameter("negativeMarks");
        String courseIdStr = req.getParameter("courseId");
        Part   csvPart     = req.getPart("csvFile");

        if (title == null || title.isBlank()) throw new IllegalArgumentException("Title is required");
        if (answerKeyRaw.isBlank())            throw new IllegalArgumentException("Answer key is required");
        if (csvPart == null || csvPart.getSize() == 0) throw new IllegalArgumentException("CSV file is required");

        String[] keyArr = Arrays.stream(answerKeyRaw.split(","))
                                .map(OMRServlet::normalizeAnswer)
                                .filter(s -> !s.isEmpty())
                                .toArray(String[]::new);
        int totalQ = keyArr.length;
        if (totalQ == 0) throw new IllegalArgumentException("Answer key must have at least 1 answer");
        // Rebuild a clean key string for storage (no spaces, uppercase, normalized)
        String cleanKey = String.join(",", keyArr);

        BigDecimal mpc    = new BigDecimal(mpcStr == null || mpcStr.isBlank() ? "1" : mpcStr);
        BigDecimal neg    = new BigDecimal(negStr == null || negStr.isBlank() ? "0" : negStr);
        BigDecimal total  = mpc.multiply(new BigDecimal(totalQ));
        Integer  courseId = (courseIdStr == null || courseIdStr.isBlank()) ? null : Integer.parseInt(courseIdStr);

        int evalId;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "INSERT INTO omr_evaluations (teacher_id, course_id, title, total_questions, " +
                "marks_per_correct, negative_marks, answer_key, total_marks) VALUES (?,?,?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, user.getId());
            if (courseId != null) ps.setInt(2, courseId); else ps.setNull(2, Types.INTEGER);
            ps.setString(3, title);
            ps.setInt(4, totalQ);
            ps.setBigDecimal(5, mpc);
            ps.setBigDecimal(6, neg);
            ps.setString(7, cleanKey);    // store normalized key, not raw
            ps.setBigDecimal(8, total);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys(); keys.next();
            evalId = keys.getInt(1);
        }

        try (Connection con = DBConfig.getConnection();
             BufferedReader reader = new BufferedReader(
                new InputStreamReader(csvPart.getInputStream(), StandardCharsets.UTF_8));
             PreparedStatement insert = con.prepareStatement(
                "INSERT INTO omr_results (evaluation_id, student_id, student_identifier, student_name, " +
                "responses, correct_count, wrong_count, unattempted_count, marks_obtained, percentage) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?)")) {

            String line;
            boolean first = true;
            while ((line = reader.readLine()) != null) {
                line = line.replace("﻿", "").trim(); // strip BOM + whitespace
                if (line.isEmpty()) continue;
                if (first) { first = false; continue; } // skip header row

                String[] cols = splitCSV(line);
                if (cols.length < 2) continue;

                String identifier = cols[0].replace("﻿", "").trim();
                if (identifier.isEmpty()) continue;

                int correct = 0, wrong = 0, unattempted = 0;
                StringBuilder responses = new StringBuilder();
                for (int i = 0; i < totalQ; i++) {
                    String ans = normalizeAnswer(i + 1 < cols.length ? cols[i + 1] : "");
                    if (i > 0) responses.append(",");
                    if (ans.isEmpty()) {
                        responses.append("-");
                        unattempted++;
                    } else {
                        responses.append(ans);
                        if (ans.equals(keyArr[i])) correct++;
                        else                        wrong++;
                    }
                }

                BigDecimal marks = mpc.multiply(new BigDecimal(correct))
                                      .subtract(neg.multiply(new BigDecimal(wrong)));
                if (marks.compareTo(BigDecimal.ZERO) < 0) marks = BigDecimal.ZERO;
                BigDecimal pct = total.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO
                    : marks.multiply(BigDecimal.valueOf(100)).divide(total, 2, RoundingMode.HALF_UP);

                // Match student in users table
                Integer studentDbId = null;
                String  studentName = null;
                try (PreparedStatement lk = con.prepareStatement(
                        "SELECT id, first_name, last_name FROM users WHERE email=? OR username=? LIMIT 1")) {
                    lk.setString(1, identifier); lk.setString(2, identifier);
                    ResultSet rs = lk.executeQuery();
                    if (rs.next()) {
                        studentDbId = rs.getInt("id");
                        studentName = (rs.getString("first_name") + " " + rs.getString("last_name")).trim();
                    }
                }

                insert.setInt(1, evalId);
                if (studentDbId != null) insert.setInt(2, studentDbId); else insert.setNull(2, Types.INTEGER);
                insert.setString(3, identifier);
                insert.setString(4, studentName);
                insert.setString(5, responses.toString());
                insert.setInt(6, correct);
                insert.setInt(7, wrong);
                insert.setInt(8, unattempted);
                insert.setBigDecimal(9, marks.setScale(2, RoundingMode.HALF_UP));
                insert.setBigDecimal(10, pct);
                insert.addBatch();
            }
            insert.executeBatch();
        }

        resp.sendRedirect(req.getContextPath() + "/omr?action=view&id=" + evalId);
    }

    // ── Export ────────────────────────────────────────────────────────────────

    private void exportCSV(HttpServletResponse resp, int evalId, int teacherId)
            throws SQLException, IOException {
        // Verify ownership
        String evalTitle;
        String answerKey;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT title, answer_key FROM omr_evaluations WHERE id=? AND teacher_id=?")) {
            ps.setInt(1, evalId); ps.setInt(2, teacherId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) return;
            evalTitle = rs.getString("title");
            answerKey = rs.getString("answer_key");
        }

        resp.setContentType("text/csv;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment;filename=\"omr_" + evalId + "_results.csv\"");
        PrintWriter w = resp.getWriter();
        w.println("Rank,Student Identifier,Student Name,Responses,Correct,Wrong,Unattempted,Marks,Percentage");
        w.println("Answer Key,,,\"" + answerKey + "\",,,,,");

        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM omr_results WHERE evaluation_id=? ORDER BY marks_obtained DESC")) {
            ps.setInt(1, evalId);
            ResultSet rs = ps.executeQuery();
            int rank = 1;
            while (rs.next()) {
                w.printf("%d,\"%s\",\"%s\",\"%s\",%d,%d,%d,%.2f,%.2f%n",
                    rank++,
                    safe(rs.getString("student_identifier")),
                    safe(rs.getString("student_name")),
                    safe(rs.getString("responses")),
                    rs.getInt("correct_count"),
                    rs.getInt("wrong_count"),
                    rs.getInt("unattempted_count"),
                    rs.getBigDecimal("marks_obtained").doubleValue(),
                    rs.getBigDecimal("percentage").doubleValue());
            }
        }
        w.flush();
    }

    private void deleteEvaluation(int evalId, int teacherId) throws SQLException {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "DELETE FROM omr_evaluations WHERE id=? AND teacher_id=?")) {
            ps.setInt(1, evalId); ps.setInt(2, teacherId);
            ps.executeUpdate();
        }
    }

    // ── Utility ───────────────────────────────────────────────────────────────

    /**
     * Normalizes an OMR answer to a clean uppercase string.
     * - Strips whitespace, control chars, brackets, dots, punctuation
     * - Converts numeric options: 1→A, 2→B, 3→C, 4→D
     * - Returns "" for blank / dash / "N/A" / 0 (treated as unattempted)
     */
    private static String normalizeAnswer(String raw) {
        if (raw == null) return "";
        String s = raw.trim();
        if (s.isEmpty() || s.equals("-") || s.equalsIgnoreCase("N/A") || s.equals("0")) return "";
        // Keep only letters and digits, uppercase
        s = s.toUpperCase().replaceAll("[^A-Z0-9]", "");
        if (s.isEmpty()) return "";
        // Convert numeric MCQ options to letters
        switch (s) {
            case "1": return "A";
            case "2": return "B";
            case "3": return "C";
            case "4": return "D";
            default:  return s;
        }
    }

    private String[] splitCSV(String line) {
        List<String> cols = new ArrayList<>();
        boolean inQ = false;
        StringBuilder cur = new StringBuilder();
        for (char c : line.toCharArray()) {
            if (c == '"') { inQ = !inQ; }
            else if (c == ',' && !inQ) { cols.add(cur.toString()); cur = new StringBuilder(); }
            else { cur.append(c); }
        }
        cols.add(cur.toString());
        return cols.toArray(new String[0]);
    }

    private String safe(String s) { return s == null ? "" : s; }
}
