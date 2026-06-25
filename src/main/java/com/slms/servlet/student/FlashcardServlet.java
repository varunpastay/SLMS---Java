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

@WebServlet("/flashcards")
public class FlashcardServlet extends HttpServlet {

    private String geminiApiKey;
    private static final String GEMINI_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=";
    private final ObjectMapper mapper = new ObjectMapper();
    private final HttpClient http = HttpClient.newHttpClient();

    @Override
    public void init() throws ServletException {
        try {
            String envKey = System.getenv("GEMINI_API_KEY");
            if (envKey != null && !envKey.isEmpty()) { geminiApiKey = envKey; return; }
            InputStream in = getClass().getResourceAsStream("/db.properties");
            if (in != null) { Properties p = new Properties(); p.load(in); in.close();
                geminiApiKey = p.getProperty("gemini.api.key", ""); }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        try (Connection con = DBConfig.getConnection()) {
            if ("list".equals(action)) {
                String courseFilter = req.getParameter("courseId");
                String sql = "SELECT f.*, c.title as course_title FROM flashcards f " +
                             "LEFT JOIN courses c ON f.course_id=c.id WHERE f.student_id=?";
                if (courseFilter != null && !courseFilter.isBlank()) sql += " AND f.course_id=" + Integer.parseInt(courseFilter);
                sql += " ORDER BY f.created_at DESC";
                ArrayNode arr = mapper.createArrayNode();
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        ObjectNode n = mapper.createObjectNode();
                        n.put("id", rs.getInt("id"));
                        n.put("front", rs.getString("front_text"));
                        n.put("back", rs.getString("back_text"));
                        n.put("courseTitle", rs.getString("course_title"));
                        arr.add(n);
                    }
                }
                resp.getWriter().write(arr.toString());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM flashcards WHERE id=? AND student_id=?")) {
                    ps.setInt(1, id); ps.setInt(2, user.getId()); ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            } else {
                // Page load - forward to JSP
                List<Map<String,Object>> courses = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT c.id, c.title FROM courses c JOIN enrollments e ON c.id=e.course_id WHERE e.student_id=? ORDER BY c.title")) {
                    ps.setInt(1, user.getId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Map<String,Object> m = new LinkedHashMap<>();
                        m.put("id", rs.getInt("id")); m.put("title", rs.getString("title")); courses.add(m);
                    }
                }
                resp.setContentType("text/html;charset=UTF-8");
                req.setAttribute("courses", courses);
                req.getRequestDispatcher("/views/student/flashcards.jsp").forward(req, resp);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");

        try {
            if ("generate".equals(action)) {
                String topic = req.getParameter("topic");
                String courseIdStr = req.getParameter("courseId");
                Integer courseId = (courseIdStr != null && !courseIdStr.isBlank()) ? Integer.parseInt(courseIdStr) : null;
                List<Map<String,String>> cards = generateFlashcards(topic);
                // Save to DB
                try (Connection con = DBConfig.getConnection();
                     PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO flashcards (student_id, course_id, front_text, back_text) VALUES (?,?,?,?)")) {
                    for (Map<String,String> card : cards) {
                        ps.setInt(1, user.getId());
                        if (courseId != null) ps.setInt(2, courseId); else ps.setNull(2, java.sql.Types.INTEGER);
                        ps.setString(3, card.get("front")); ps.setString(4, card.get("back"));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                ArrayNode out = mapper.createArrayNode();
                cards.forEach(c -> { ObjectNode n = mapper.createObjectNode(); n.put("front", c.get("front")); n.put("back", c.get("back")); out.add(n); });
                ObjectNode res = mapper.createObjectNode(); res.set("cards", out);
                resp.getWriter().write(res.toString());
            } else if ("add".equals(action)) {
                String front = req.getParameter("front"); String back = req.getParameter("back");
                String cId = req.getParameter("courseId");
                try (Connection con = DBConfig.getConnection();
                     PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO flashcards (student_id, course_id, front_text, back_text) VALUES (?,?,?,?)")) {
                    ps.setInt(1, user.getId());
                    if (cId != null && !cId.isBlank()) ps.setInt(2, Integer.parseInt(cId)); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.setString(3, front); ps.setString(4, back); ps.executeUpdate();
                }
                resp.getWriter().write("{\"ok\":true}");
            }
        } catch (Exception e) {
            ObjectNode err = mapper.createObjectNode(); err.put("error", e.getMessage());
            resp.getWriter().write(err.toString());
        }
    }

    private List<Map<String,String>> generateFlashcards(String topic) throws Exception {
        String prompt = String.format("""
            Generate 8 flashcards for the topic: "%s"
            Return ONLY valid JSON (no markdown):
            {"cards":[{"front":"Question or term?","back":"Answer or definition."}]}
            Make cards concise, educational, and varied (definitions, examples, formulas, concepts).
            """, topic);

        ObjectNode body = mapper.createObjectNode();
        ArrayNode contents = mapper.createArrayNode();
        ObjectNode content = mapper.createObjectNode();
        ArrayNode parts = mapper.createArrayNode();
        ObjectNode tp = mapper.createObjectNode(); tp.put("text", prompt);
        parts.add(tp); content.set("parts", parts); contents.add(content); body.set("contents", contents);
        ObjectNode cfg = mapper.createObjectNode();
        cfg.put("temperature", 0.3); cfg.put("maxOutputTokens", 4096);
        ObjectNode thinking = mapper.createObjectNode(); thinking.put("thinkingBudget", 0);
        cfg.set("thinkingConfig", thinking); body.set("generationConfig", cfg);

        HttpRequest req = HttpRequest.newBuilder().uri(URI.create(GEMINI_URL + geminiApiKey))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(body))).build();
        HttpResponse<String> res = http.send(req, HttpResponse.BodyHandlers.ofString());
        if (res.statusCode() != 200) throw new RuntimeException("Gemini error");
        JsonNode root = mapper.readTree(res.body());
        String text = root.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText().trim();
        if (text.contains("```")) text = text.replaceAll("(?s)^.*?```[a-zA-Z]*\\n?","").replaceAll("(?s)```.*$","").trim();
        int s = text.indexOf('{'); int e = text.lastIndexOf('}');
        if (s >= 0 && e > s) text = text.substring(s, e+1);
        JsonNode data = mapper.readTree(text);
        List<Map<String,String>> cards = new ArrayList<>();
        for (JsonNode c : data.path("cards")) {
            Map<String,String> m = new HashMap<>();
            m.put("front", c.path("front").asText()); m.put("back", c.path("back").asText()); cards.add(m);
        }
        return cards;
    }
}
