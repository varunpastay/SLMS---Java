package com.slms.servlet.student;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.slms.config.DBConfig;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.sql.*;
import java.util.*;

@WebServlet("/ai-doubt")
public class AIDoubtServlet extends HttpServlet {

    private String geminiApiKey;
    private static final String GEMINI_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=";
    private final ObjectMapper mapper = new ObjectMapper();
    private final HttpClient http = HttpClient.newHttpClient();

    @Override
    public void init() throws ServletException {
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties p = new Properties(); p.load(in);
            geminiApiKey = p.getProperty("gemini.api.key", "");
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        // Load enrolled courses for subject context
        List<Map<String, Object>> courses = new ArrayList<>();
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT c.id, c.title FROM courses c JOIN enrollments e ON c.id=e.course_id " +
                "WHERE e.student_id=? ORDER BY c.title")) {
            ps.setInt(1, user.getId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id")); m.put("title", rs.getString("title"));
                courses.add(m);
            }
        } catch (SQLException e) { throw new ServletException(e); }
        req.setAttribute("courses", courses);
        req.getRequestDispatcher("/views/student/aiDoubt.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        resp.setContentType("application/json;charset=UTF-8");
        String question = req.getParameter("question");
        String subject  = req.getParameter("subject");
        if (question == null || question.isBlank()) { error(resp, "Question is required"); return; }

        String prompt = String.format("""
            You are an expert AI tutor helping a student.
            %s
            Student's question: %s

            Give a clear, step-by-step explanation suitable for a student.
            Use simple language, real-world examples, and be encouraging.
            Format your answer with:
            1. A short direct answer (1-2 sentences)
            2. Detailed explanation with steps/examples
            3. A quick tip or memory trick if applicable
            Keep total response under 300 words. Do not use markdown headers.
            """,
            (subject != null && !subject.isBlank()) ? "Subject context: " + subject : "",
            question);

        try {
            String answer = callGemini(prompt);
            ObjectNode out = mapper.createObjectNode();
            out.put("answer", answer);
            resp.getWriter().write(mapper.writeValueAsString(out));
        } catch (Exception e) {
            error(resp, "AI error: " + e.getMessage());
        }
    }

    private String callGemini(String prompt) throws Exception {
        ObjectNode body = mapper.createObjectNode();
        ArrayNode contents = mapper.createArrayNode();
        ObjectNode content = mapper.createObjectNode();
        ArrayNode parts = mapper.createArrayNode();
        ObjectNode textPart = mapper.createObjectNode();
        textPart.put("text", prompt);
        parts.add(textPart); content.set("parts", parts); contents.add(content);
        body.set("contents", contents);
        ObjectNode cfg = mapper.createObjectNode();
        cfg.put("temperature", 0.4); cfg.put("maxOutputTokens", 2048);
        ObjectNode thinking = mapper.createObjectNode(); thinking.put("thinkingBudget", 0);
        cfg.set("thinkingConfig", thinking);
        body.set("generationConfig", cfg);

        HttpRequest req = HttpRequest.newBuilder()
            .uri(URI.create(GEMINI_URL + geminiApiKey))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(body))).build();
        HttpResponse<String> res = http.send(req, HttpResponse.BodyHandlers.ofString());
        if (res.statusCode() != 200) throw new RuntimeException("Gemini error: " + res.body());
        JsonNode root = mapper.readTree(res.body());
        return root.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();
    }

    private void error(HttpServletResponse resp, String msg) throws IOException {
        ObjectNode e = mapper.createObjectNode(); e.put("error", msg);
        resp.getWriter().write(mapper.writeValueAsString(e));
    }
}
