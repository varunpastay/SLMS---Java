package com.slms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class EmailUtil {

    private static Session mailSession;
    private static String fromAddress;

    static {
        try (InputStream in = EmailUtil.class.getResourceAsStream("/db.properties")) {
            Properties props = new Properties();
            props.load(in);

            fromAddress = props.getProperty("mail.from", "SLMS <noreply@slms.com>");
            String host = props.getProperty("mail.host", "smtp.gmail.com");
            String port = props.getProperty("mail.port", "587");
            final String username = props.getProperty("mail.username", "");
            final String password = props.getProperty("mail.password", "");

            Properties mailProps = new Properties();
            mailProps.put("mail.smtp.host", host);
            mailProps.put("mail.smtp.port", port);
            mailProps.put("mail.smtp.auth", "true");
            mailProps.put("mail.smtp.starttls.enable", "true");

            mailSession = Session.getInstance(mailProps, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void send(String toEmail, String subject, String htmlBody) {
        try {
            MimeMessage msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(fromAddress));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            msg.setSubject(subject, "UTF-8");
            msg.setContent(htmlBody, "text/html; charset=UTF-8");
            Transport.send(msg);
        } catch (MessagingException e) {
            System.err.println("[EmailUtil] Failed to send email to " + toEmail + ": " + e.getMessage());
        }
    }

    public static void sendOtp(String toEmail, String name, String otp) {
        String body = "<div style='font-family:sans-serif;max-width:480px;margin:auto;border:1px solid #dee2e6;border-radius:8px;padding:32px'>" +
                      "<h2 style='color:#0d6efd'>SLMS – Email Verification</h2>" +
                      "<p>Hi <strong>" + name + "</strong>,</p>" +
                      "<p>Use the OTP below to complete your registration. It expires in <strong>5 minutes</strong>.</p>" +
                      "<div style='font-size:2.5rem;font-weight:700;letter-spacing:12px;text-align:center;" +
                      "background:#f0f4ff;border-radius:6px;padding:16px 0;color:#0d6efd'>" + otp + "</div>" +
                      "<p style='margin-top:20px;color:#6c757d;font-size:.9rem'>If you did not request this, ignore this email.</p>" +
                      "</div>";
        send(toEmail, "Your SLMS Registration OTP", body);
    }

    public static void sendWelcome(String toEmail, String name) {
        String body = "<div style='font-family:sans-serif;max-width:480px;margin:auto;border:1px solid #dee2e6;border-radius:8px;padding:32px'>" +
                      "<h2 style='color:#0d6efd'>Welcome to SLMS!</h2>" +
                      "<p>Hi <strong>" + name + "</strong>,</p>" +
                      "<p>Your account has been verified and created successfully.</p>" +
                      "<p>You can now <a href='http://localhost:8081/slms/login' style='color:#0d6efd'>log in</a> and start learning today!</p>" +
                      "<p style='color:#6c757d;font-size:.9rem'>The SLMS Team</p>" +
                      "</div>";
        send(toEmail, "Welcome to SLMS!", body);
    }

    public static void sendEnrollmentConfirmation(String toEmail, String name, String courseTitle) {
        String body = "<h2>Enrollment Confirmed</h2>" +
                      "<p>Hi " + name + ", you have successfully enrolled in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "Enrollment Confirmed: " + courseTitle, body);
    }

    public static void sendAssignmentGraded(String toEmail, String name, String assignmentTitle, String marks, String feedback) {
        String body = "<h2>Assignment Graded</h2>" +
                      "<p>Hi " + name + ", your assignment <strong>" + assignmentTitle + "</strong> has been graded.</p>" +
                      "<p><strong>Marks:</strong> " + marks + "</p>" +
                      "<p><strong>Feedback:</strong> " + feedback + "</p>";
        send(toEmail, "Assignment Graded: " + assignmentTitle, body);
    }

    public static void sendQuizResult(String toEmail, String name, String quizTitle, String score, boolean passed) {
        String status = passed ? "PASSED" : "FAILED";
        String body = "<h2>Quiz Result</h2>" +
                      "<p>Hi " + name + ", here is your result for <strong>" + quizTitle + "</strong>.</p>" +
                      "<p><strong>Score:</strong> " + score + "%</p>" +
                      "<p><strong>Status:</strong> " + status + "</p>";
        send(toEmail, "Quiz Result: " + quizTitle, body);
    }

    public static void sendNewAssignmentNotice(String toEmail, String name, String courseTitle, String assignmentTitle) {
        String body = "<h2>New Assignment Posted</h2>" +
                      "<p>Hi " + name + ", a new assignment <strong>" + assignmentTitle +
                      "</strong> has been posted in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "New Assignment: " + assignmentTitle, body);
    }

    public static void sendNewQuizNotice(String toEmail, String name, String courseTitle, String quizTitle) {
        String body = "<h2>New Quiz Posted</h2>" +
                      "<p>Hi " + name + ", a new quiz <strong>" + quizTitle +
                      "</strong> has been posted in <strong>" + courseTitle + "</strong>.</p>";
        send(toEmail, "New Quiz: " + quizTitle, body);
    }

    private EmailUtil() {}
}
