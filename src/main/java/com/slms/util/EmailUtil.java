package com.slms.util;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class EmailUtil {

    private static final String API_URL = "https://api.brevo.com/v3/smtp/email";
    private static String apiKey;
    private static String fromName;
    private static String fromEmail;

    static {
        try {
            Properties props = new Properties();
            InputStream in = EmailUtil.class.getResourceAsStream("/db.properties");
            if (in != null) { props.load(in); in.close(); }

            apiKey = env("BREVO_API_KEY", props.getProperty("brevo.api.key", ""));

            String from = env("MAIL_FROM", props.getProperty("mail.from", "SLMS <noreply@slms.com>"));
            if (from.contains("<") && from.contains(">")) {
                fromName  = from.substring(0, from.indexOf("<")).trim();
                fromEmail = from.substring(from.indexOf("<") + 1, from.indexOf(">")).trim();
            } else {
                fromName  = "SLMS";
                fromEmail = from.trim();
            }

            if (apiKey == null || apiKey.isEmpty()) {
                System.out.println("[EmailUtil] BREVO_API_KEY not set — emails disabled");
            } else {
                System.out.println("[EmailUtil] Brevo API configured, from=" + fromEmail);
            }
        } catch (Exception e) {
            System.out.println("[EmailUtil] Init error: " + e.getMessage());
        }
    }

    private static String env(String key, String fallback) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : fallback;
    }

    public static void send(String toEmail, String subject, String htmlBody) {
        if (apiKey == null || apiKey.isEmpty()) {
            System.out.println("[EmailUtil] Skipping email to " + toEmail + " — no API key");
            return;
        }
        try {
            String safe = htmlBody
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "");

            String json = "{"
                + "\"sender\":{\"name\":\"" + fromName + "\",\"email\":\"" + fromEmail + "\"},"
                + "\"to\":[{\"email\":\"" + toEmail + "\"}],"
                + "\"subject\":\"" + subject.replace("\"", "\\\"") + "\","
                + "\"htmlContent\":\"" + safe + "\""
                + "}";

            HttpURLConnection conn = (HttpURLConnection) new URL(API_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("api-key", apiKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(json.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            if (status == 201) {
                System.out.println("[EmailUtil] Email sent to " + toEmail);
            } else {
                InputStream err = conn.getErrorStream();
                String body = err != null ? new String(err.readAllBytes(), StandardCharsets.UTF_8) : "";
                System.out.println("[EmailUtil] Brevo error " + status + ": " + body);
            }
        } catch (Exception e) {
            System.out.println("[EmailUtil] Failed to send to " + toEmail + ": " + e.getMessage());
        }
    }

    public static void sendOtp(String toEmail, String name, String otp) {
        String body = "<div style='font-family:sans-serif;max-width:480px;margin:auto;border:1px solid #dee2e6;border-radius:8px;padding:32px'>"
                + "<h2 style='color:#0d6efd'>SLMS – Email Verification</h2>"
                + "<p>Hi <strong>" + name + "</strong>,</p>"
                + "<p>Use the OTP below to complete your registration. It expires in <strong>5 minutes</strong>.</p>"
                + "<div style='font-size:2.5rem;font-weight:700;letter-spacing:12px;text-align:center;"
                + "background:#f0f4ff;border-radius:6px;padding:16px 0;color:#0d6efd'>" + otp + "</div>"
                + "<p style='margin-top:20px;color:#6c757d;font-size:.9rem'>If you did not request this, ignore this email.</p>"
                + "</div>";
        send(toEmail, "Your SLMS Registration OTP", body);
    }

    public static void sendWelcome(String toEmail, String name) {
        String body = "<div style='font-family:sans-serif;max-width:480px;margin:auto;border:1px solid #dee2e6;border-radius:8px;padding:32px'>"
                + "<h2 style='color:#0d6efd'>Welcome to SLMS!</h2>"
                + "<p>Hi <strong>" + name + "</strong>,</p>"
                + "<p>Your account has been verified and created successfully.</p>"
                + "<p>You can now <a href='https://slms-java.onrender.com/login' style='color:#0d6efd'>log in</a> and start learning today!</p>"
                + "<p style='color:#6c757d;font-size:.9rem'>The SLMS Team</p>"
                + "</div>";
        send(toEmail, "Welcome to SLMS!", body);
    }

    public static void sendEnrollmentConfirmation(String toEmail, String name, String courseTitle) {
        String body = "<h2>Enrollment Confirmed</h2>"
                + "<p>Hi " + name + ", you have successfully enrolled in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "Enrollment Confirmed: " + courseTitle, body);
    }

    public static void sendAssignmentGraded(String toEmail, String name, String assignmentTitle, String marks, String feedback) {
        String body = "<h2>Assignment Graded</h2>"
                + "<p>Hi " + name + ", your assignment <strong>" + assignmentTitle + "</strong> has been graded.</p>"
                + "<p><strong>Marks:</strong> " + marks + "</p>"
                + "<p><strong>Feedback:</strong> " + feedback + "</p>";
        send(toEmail, "Assignment Graded: " + assignmentTitle, body);
    }

    public static void sendQuizResult(String toEmail, String name, String quizTitle, String score, boolean passed) {
        String status = passed ? "PASSED" : "FAILED";
        String body = "<h2>Quiz Result</h2>"
                + "<p>Hi " + name + ", here is your result for <strong>" + quizTitle + "</strong>.</p>"
                + "<p><strong>Score:</strong> " + score + "%</p>"
                + "<p><strong>Status:</strong> " + status + "</p>";
        send(toEmail, "Quiz Result: " + quizTitle, body);
    }

    public static void sendNewAssignmentNotice(String toEmail, String name, String courseTitle, String assignmentTitle) {
        String body = "<h2>New Assignment Posted</h2>"
                + "<p>Hi " + name + ", a new assignment <strong>" + assignmentTitle
                + "</strong> has been posted in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "New Assignment: " + assignmentTitle, body);
    }

    public static void sendNewQuizNotice(String toEmail, String name, String courseTitle, String quizTitle) {
        String body = "<h2>New Quiz Posted</h2>"
                + "<p>Hi " + name + ", a new quiz <strong>" + quizTitle
                + "</strong> has been posted in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "New Quiz: " + quizTitle, body);
    }

    public static void sendPasswordReset(String toEmail, String name, String resetLink) {
        String body = "<div style='font-family:sans-serif;max-width:480px;margin:auto;border:1px solid #dee2e6;border-radius:8px;padding:32px'>"
                + "<h2 style='color:#0d6efd'>SLMS – Password Reset</h2>"
                + "<p>Hi <strong>" + name + "</strong>,</p>"
                + "<p>We received a request to reset your password. Click the button below. The link expires in <strong>30 minutes</strong>.</p>"
                + "<div style='text-align:center;margin:24px 0'>"
                + "<a href='" + resetLink + "' style='background:#0d6efd;color:#fff;padding:12px 28px;"
                + "border-radius:6px;text-decoration:none;font-weight:600'>Reset Password</a></div>"
                + "<p style='color:#6c757d;font-size:.9rem'>If you did not request this, you can safely ignore this email.</p>"
                + "</div>";
        send(toEmail, "SLMS – Reset Your Password", body);
    }

    private EmailUtil() {}
}
