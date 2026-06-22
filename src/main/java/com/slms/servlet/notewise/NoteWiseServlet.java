package com.slms.servlet.notewise;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
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
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.*;
import java.sql.*;
import java.util.*;

@WebServlet("/notewise")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 15 * 1024 * 1024)
public class NoteWiseServlet extends HttpServlet {

    private String geminiApiKey;
    private String uploadDir;

    private static final String GEMINI_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=";

    private final ObjectMapper mapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Override
    public void init() throws ServletException {
        try (InputStream in = getClass().getResourceAsStream("/db.properties")) {
            Properties props = new Properties();
            props.load(in);
            geminiApiKey = props.getProperty("gemini.api.key", "");
            uploadDir = props.getProperty("upload.dir", "C:/slms_uploads") + "/notewise";
            Files.createDirectories(Paths.get(uploadDir));
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── GET: render the NoteWise page ─────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);

        try (Connection con = DBConfig.getConnection()) {

            List<Map<String, Object>> sessions = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id, topic, difficulty, study_minutes, summary, created_at " +
                    "FROM notewise_sessions WHERE student_id=? ORDER BY created_at DESC LIMIT 10")) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> s = new LinkedHashMap<>();
                    s.put("id",           rs.getInt("id"));
                    s.put("topic",        rs.getString("topic"));
                    s.put("difficulty",   rs.getString("difficulty"));
                    s.put("studyMinutes", rs.getInt("study_minutes"));
                    s.put("summary",      rs.getString("summary"));
                    s.put("createdAt",    rs.getString("created_at"));
                    sessions.add(s);
                }
            }

            int totalXp = 0, streak = 0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT total_xp, streak_days FROM notewise_xp WHERE student_id=?")) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    totalXp = rs.getInt("total_xp");
                    streak  = rs.getInt("streak_days");
                }
            }

            req.setAttribute("nwSessions",  mapper.writeValueAsString(sessions));
            req.setAttribute("totalXp",     totalXp);
            req.setAttribute("streak",      streak);
            req.getRequestDispatcher("/views/notewise/notewise.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ── POST: dispatch by action ──────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
        UserDTO user = SessionUtil.getLoggedUser(req);
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "analyze" -> handleAnalyze(req, resp, user);
                case "quiz"    -> handleQuiz(req, resp, user);
                case "submit"  -> handleSubmitQuiz(req, resp, user);
                case "chat"    -> handleChat(req, resp, user);
                case "load"    -> handleLoadSession(req, resp, user);
                default        -> jsonError(resp, "Unknown action");
            }
        } catch (Exception e) {
            resp.setStatus(500);
            jsonError(resp, e.getMessage() != null ? e.getMessage() : "Internal error");
        }
    }

    // ── Analyze: upload image → Gemini → save session ─────────────────────────

    private void handleAnalyze(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        Part filePart = req.getPart("noteImage");
        if (filePart == null || filePart.getSize() == 0) {
            jsonError(resp, "No image uploaded"); return;
        }

        String fileName = System.currentTimeMillis() + "_" + user.getId()
                          + ext(filePart.getSubmittedFileName());
        Path savePath = Paths.get(uploadDir, fileName);
        try (InputStream is = filePart.getInputStream()) {
            Files.copy(is, savePath, StandardCopyOption.REPLACE_EXISTING);
        }

        byte[] imageBytes = Files.readAllBytes(savePath);
        String base64     = Base64.getEncoder().encodeToString(imageBytes);
        String mimeType   = filePart.getContentType() != null ? filePart.getContentType() : "image/jpeg";

        String prompt = """
            You are an AI tutor analyzing a student's handwritten notes image.

            Carefully read every word visible in the image, then respond with ONLY a valid JSON object \
            (absolutely no markdown, no code fences, no explanation — just raw JSON):
            {
              "topic": "The main subject title from the notes",
              "extractedText": "All readable text from the image, organized clearly",
              "concepts": ["concept1", "concept2", "concept3"],
              "difficulty": "Intermediate",
              "studyTimeMinutes": 10,
              "summary": "A 2-sentence summary of what the notes cover.",
              "explanation": "Write as Ms. Clara, a warm encouraging teacher. Explain every concept with simple language and real-world examples. Be friendly and motivating. 300-400 words."
            }

            Rules: difficulty ∈ {Beginner, Intermediate, Advanced}; concepts: 3-6 items; studyTimeMinutes: 5-30.
            """;

        String geminiResp = callGemini(base64, mimeType, prompt);
        JsonNode data      = parseJson(geminiResp);

        int sessionId;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "INSERT INTO notewise_sessions " +
                "(student_id, image_path, topic, difficulty, study_minutes, extracted_text, concepts, summary, explanation) " +
                "VALUES (?,?,?,?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, user.getId());
            ps.setString(2, "notewise/" + fileName);
            ps.setString(3, data.path("topic").asText("Untitled"));
            ps.setString(4, data.path("difficulty").asText("Intermediate"));
            ps.setInt(5,    data.path("studyTimeMinutes").asInt(10));
            ps.setString(6, data.path("extractedText").asText(""));
            ps.setString(7, data.path("concepts").toString());
            ps.setString(8, data.path("summary").asText(""));
            ps.setString(9, data.path("explanation").asText(""));
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys(); keys.next();
            sessionId = keys.getInt(1);
        }

        awardXp(user.getId(), 50);

        ObjectNode out = mapper.createObjectNode();
        out.put("sessionId",       sessionId);
        out.put("topic",           data.path("topic").asText());
        out.put("extractedText",   data.path("extractedText").asText());
        out.set("concepts",        data.path("concepts"));
        out.put("difficulty",      data.path("difficulty").asText());
        out.put("studyTimeMinutes",data.path("studyTimeMinutes").asInt());
        out.put("summary",         data.path("summary").asText());
        out.put("explanation",     data.path("explanation").asText());
        out.put("xpEarned",        50);
        write(resp, out);
    }

    // ── Quiz: generate 5 MCQs from session notes ──────────────────────────────

    private void handleQuiz(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        int sessionId = intParam(req, "sessionId");
        String topic, text;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT topic, extracted_text FROM notewise_sessions WHERE id=? AND student_id=?")) {
            ps.setInt(1, sessionId); ps.setInt(2, user.getId());
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { jsonError(resp, "Session not found"); return; }
            topic = rs.getString("topic");
            text  = rs.getString("extracted_text");
        }

        String prompt = """
            Based on these student notes about "%s":
            %s

            Generate exactly 5 multiple choice questions testing understanding.
            Return ONLY valid JSON (no markdown, no code fences):
            {
              "questions": [
                {
                  "q": "Question?",
                  "a": "Option A", "b": "Option B", "c": "Option C", "d": "Option D",
                  "correct": "a",
                  "explanation": "Why this is correct and what the wrong choices missed."
                }
              ]
            }
            Rules: correct ∈ {"a","b","c","d"} (lowercase); vary difficulty; make explanations helpful.
            """.formatted(topic, text);

        String geminiResp = callGeminiText(prompt);
        JsonNode quizData  = parseJson(geminiResp);

        int quizId;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "INSERT INTO notewise_quizzes (session_id, student_id, questions_json, total) VALUES (?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, sessionId); ps.setInt(2, user.getId());
            ps.setString(3, quizData.path("questions").toString());
            ps.setInt(4,    quizData.path("questions").size());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys(); keys.next();
            quizId = keys.getInt(1);
        }

        // Send questions to client WITHOUT correct answers
        ArrayNode clientQs = mapper.createArrayNode();
        for (JsonNode q : quizData.path("questions")) {
            ObjectNode cq = mapper.createObjectNode();
            cq.put("q", q.path("q").asText());
            cq.put("a", q.path("a").asText());
            cq.put("b", q.path("b").asText());
            cq.put("c", q.path("c").asText());
            cq.put("d", q.path("d").asText());
            clientQs.add(cq);
        }
        ObjectNode out = mapper.createObjectNode();
        out.put("quizId", quizId);
        out.set("questions", clientQs);
        write(resp, out);
    }

    // ── Submit Quiz: score answers and return results ─────────────────────────

    private void handleSubmitQuiz(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        int quizId          = intParam(req, "quizId");
        String answersJson  = req.getParameter("answers");
        JsonNode answers    = mapper.readTree(answersJson);

        String questionsJson;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT questions_json FROM notewise_quizzes WHERE id=? AND student_id=?")) {
            ps.setInt(1, quizId); ps.setInt(2, user.getId());
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { jsonError(resp, "Quiz not found"); return; }
            questionsJson = rs.getString("questions_json");
        }

        JsonNode questions = mapper.readTree(questionsJson);
        int score = 0;
        ArrayNode results = mapper.createArrayNode();

        for (int i = 0; i < questions.size(); i++) {
            JsonNode q   = questions.get(i);
            String correct = q.path("correct").asText();
            String given   = i < answers.size() ? answers.get(i).asText("") : "";
            boolean ok     = correct.equalsIgnoreCase(given);
            if (ok) score++;

            ObjectNode r = mapper.createObjectNode();
            r.put("correct",       ok);
            r.put("correctAnswer", correct);
            r.put("givenAnswer",   given);
            r.put("question",      q.path("q").asText());
            r.put("optionA",       q.path("a").asText());
            r.put("optionB",       q.path("b").asText());
            r.put("optionC",       q.path("c").asText());
            r.put("optionD",       q.path("d").asText());
            r.put("explanation",   q.path("explanation").asText());
            results.add(r);
        }

        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "UPDATE notewise_quizzes SET score=?, completed=TRUE WHERE id=?")) {
            ps.setInt(1, score); ps.setInt(2, quizId);
            ps.executeUpdate();
        }

        int xpEarned = score * 20;
        awardXp(user.getId(), xpEarned);

        ObjectNode out = mapper.createObjectNode();
        out.put("score",    score);
        out.put("total",    questions.size());
        out.put("xpEarned", xpEarned);
        out.set("results",  results);
        write(resp, out);
    }

    // ── Chat: Ms. Clara answers student doubt ─────────────────────────────────

    private void handleChat(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        int sessionId   = intParam(req, "sessionId");
        String question = req.getParameter("question");
        if (question == null || question.isBlank()) { jsonError(resp, "Empty question"); return; }

        String topic, text;
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT topic, extracted_text FROM notewise_sessions WHERE id=? AND student_id=?")) {
            ps.setInt(1, sessionId); ps.setInt(2, user.getId());
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { jsonError(resp, "Session not found"); return; }
            topic = rs.getString("topic");
            text  = rs.getString("extracted_text");
        }

        String prompt = """
            You are Ms. Clara, a warm, friendly, and encouraging AI teacher.
            The student is studying: %s

            Their notes say:
            %s

            Student's question: %s

            Answer clearly and simply. Be encouraging. Relate your answer to the notes when possible.
            Keep response under 200 words. Do not use markdown headers or bullet asterisks.
            """.formatted(topic, text, question);

        String geminiResp = callGeminiText(prompt);
        String answer      = extractText(geminiResp);

        ObjectNode out = mapper.createObjectNode();
        out.put("answer", answer);
        write(resp, out);
    }

    // ── Load past session ─────────────────────────────────────────────────────

    private void handleLoadSession(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws Exception {
        int sessionId = intParam(req, "sessionId");
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM notewise_sessions WHERE id=? AND student_id=?")) {
            ps.setInt(1, sessionId); ps.setInt(2, user.getId());
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { jsonError(resp, "Session not found"); return; }

            ObjectNode out = mapper.createObjectNode();
            out.put("sessionId",        rs.getInt("id"));
            out.put("topic",            rs.getString("topic"));
            out.put("extractedText",    rs.getString("extracted_text"));
            out.set("concepts",         mapper.readTree(rs.getString("concepts")));
            out.put("difficulty",       rs.getString("difficulty"));
            out.put("studyTimeMinutes", rs.getInt("study_minutes"));
            out.put("summary",          rs.getString("summary"));
            out.put("explanation",      rs.getString("explanation"));
            write(resp, out);
        }
    }

    // ── Gemini API helpers ────────────────────────────────────────────────────

    private String callGemini(String base64Image, String mimeType, String promptText) throws Exception {
        ObjectNode body     = mapper.createObjectNode();
        ArrayNode  contents = mapper.createArrayNode();
        ObjectNode content  = mapper.createObjectNode();
        ArrayNode  parts    = mapper.createArrayNode();

        ObjectNode imgPart   = mapper.createObjectNode();
        ObjectNode inlineData = mapper.createObjectNode();
        inlineData.put("mimeType", mimeType);
        inlineData.put("data", base64Image);
        imgPart.set("inlineData", inlineData);
        parts.add(imgPart);

        ObjectNode textPart = mapper.createObjectNode();
        textPart.put("text", promptText);
        parts.add(textPart);

        content.set("parts", parts);
        contents.add(content);
        body.set("contents", contents);

        ObjectNode cfg = mapper.createObjectNode();
        cfg.put("temperature", 0.1);
        cfg.put("maxOutputTokens", 8192);
        ObjectNode thinking = mapper.createObjectNode();
        thinking.put("thinkingBudget", 0);
        cfg.set("thinkingConfig", thinking);
        body.set("generationConfig", cfg);

        return sendToGemini(body);
    }

    private String callGeminiText(String promptText) throws Exception {
        ObjectNode body     = mapper.createObjectNode();
        ArrayNode  contents = mapper.createArrayNode();
        ObjectNode content  = mapper.createObjectNode();
        ArrayNode  parts    = mapper.createArrayNode();

        ObjectNode textPart = mapper.createObjectNode();
        textPart.put("text", promptText);
        parts.add(textPart);
        content.set("parts", parts);
        contents.add(content);
        body.set("contents", contents);

        ObjectNode cfg = mapper.createObjectNode();
        cfg.put("temperature", 0.3);
        cfg.put("maxOutputTokens", 8192);
        ObjectNode thinking = mapper.createObjectNode();
        thinking.put("thinkingBudget", 0);
        cfg.set("thinkingConfig", thinking);
        body.set("generationConfig", cfg);

        return sendToGemini(body);
    }

    private String sendToGemini(ObjectNode body) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(GEMINI_URL + geminiApiKey))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(body)))
            .build();
        HttpResponse<String> resp = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200)
            throw new RuntimeException("Gemini API error (" + resp.statusCode() + "): " + resp.body());
        return resp.body();
    }

    private JsonNode parseJson(String geminiResponse) throws Exception {
        String text = extractText(geminiResponse).trim();
        // Strip any markdown code fences
        if (text.contains("```")) {
            text = text.replaceAll("(?s)^.*?```[a-zA-Z]*\\n?", "").replaceAll("(?s)```.*$", "").trim();
        }
        // Extract only the JSON object/array portion
        int start = text.indexOf('{');
        if (start < 0) start = text.indexOf('[');
        int end   = text.lastIndexOf('}');
        int endArr = text.lastIndexOf(']');
        if (endArr > end) end = endArr;
        if (start >= 0 && end > start) {
            text = text.substring(start, end + 1);
        }
        return mapper.readTree(text);
    }

    private String extractText(String geminiResponse) throws Exception {
        JsonNode root = mapper.readTree(geminiResponse);
        return root.path("candidates").get(0)
                   .path("content").path("parts").get(0)
                   .path("text").asText();
    }

    // ── XP helper ────────────────────────────────────────────────────────────

    private void awardXp(int studentId, int xp) {
        try (Connection con = DBConfig.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "INSERT INTO notewise_xp (student_id, total_xp, streak_days, last_active) " +
                "VALUES (?, ?, 1, CURDATE()) " +
                "ON DUPLICATE KEY UPDATE " +
                "  total_xp    = total_xp + ?, " +
                "  streak_days = IF(last_active = DATE_SUB(CURDATE(), INTERVAL 1 DAY), streak_days + 1, " +
                "                  IF(last_active = CURDATE(), streak_days, 1)), " +
                "  last_active = CURDATE()")) {
            ps.setInt(1, studentId);
            ps.setInt(2, xp);
            ps.setInt(3, xp);
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }

    // ── Utility ───────────────────────────────────────────────────────────────

    private void write(HttpServletResponse resp, ObjectNode node) throws IOException {
        resp.getWriter().write(mapper.writeValueAsString(node));
    }

    private void jsonError(HttpServletResponse resp, String msg) throws IOException {
        ObjectNode e = mapper.createObjectNode();
        e.put("error", msg);
        resp.getWriter().write(mapper.writeValueAsString(e));
    }

    private int intParam(HttpServletRequest req, String name) {
        return Integer.parseInt(req.getParameter(name));
    }

    private String ext(String fileName) {
        if (fileName == null) return ".jpg";
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot).toLowerCase() : ".jpg";
    }
}
