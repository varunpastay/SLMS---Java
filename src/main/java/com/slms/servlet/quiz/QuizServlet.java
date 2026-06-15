package com.slms.servlet.quiz;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.EmailUtil;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {

    private QuizDAO quizDAO;
    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private NotificationDAO notificationDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        quizDAO         = new QuizDAOImpl();
        courseDAO       = new CourseDAOImpl();
        enrollmentDAO   = new EnrollmentDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        userDAO         = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                req.setAttribute("courseId", req.getParameter("courseId"));
                req.getRequestDispatcher("/views/quiz/quizForm.jsp").forward(req, resp);

            } else if ("take".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
                int quizId = Integer.parseInt(req.getParameter("id"));
                UserDTO student = SessionUtil.getLoggedUser(req);
                QuizAttemptDTO existing = quizDAO.findAttemptByStudentAndQuiz(student.getId(), quizId);
                if (existing != null) {
                    resp.sendRedirect(req.getContextPath() + "/quiz?action=result&attemptId=" + existing.getId());
                    return;
                }
                QuizDTO quiz = quizDAO.findQuizById(quizId);
                List<QuizQuestionDTO> questions = quizDAO.findQuestionsByQuiz(quizId);
                quiz.setQuestions(questions);
                req.setAttribute("quiz", quiz);
                req.getRequestDispatcher("/views/quiz/takeQuiz.jsp").forward(req, resp);

            } else if ("result".equals(action)) {
                int attemptId = Integer.parseInt(req.getParameter("attemptId"));
                QuizAttemptDTO attempt = null;
                UserDTO user = SessionUtil.getLoggedUser(req);
                // Find attempt
                List<QuizAttemptDTO> attempts = quizDAO.findAttemptsByStudent(user.getId());
                for (QuizAttemptDTO a : attempts) {
                    if (a.getId() == attemptId) { attempt = a; break; }
                }
                if (attempt == null) { resp.sendError(404); return; }

                QuizDTO quiz = quizDAO.findQuizById(attempt.getQuizId());
                List<QuizQuestionDTO> questions = quizDAO.findQuestionsByQuiz(quiz.getId());
                Map<Integer, Character> answers = quizDAO.findAnswersByAttempt(attemptId);
                req.setAttribute("attempt", attempt);
                req.setAttribute("quiz", quiz);
                req.setAttribute("questions", questions);
                req.setAttribute("answers", answers);
                req.getRequestDispatcher("/views/quiz/quizResult.jsp").forward(req, resp);

            } else {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                List<QuizDTO> quizzes = quizDAO.findQuizzesByCourse(courseId);
                req.setAttribute("quizzes", quizzes);
                req.setAttribute("course", courseDAO.findById(courseId));
                req.getRequestDispatcher("/views/quiz/quizList.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                createQuiz(req, resp);

            } else if ("submit".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "STUDENT")) return;
                submitQuiz(req, resp);

            } else if ("delete".equals(action)) {
                if (!SessionUtil.requireRole(req, resp, "TEACHER", "ADMIN")) return;
                int id = Integer.parseInt(req.getParameter("id"));
                QuizDTO q = quizDAO.findQuizById(id);
                quizDAO.deleteQuiz(id);
                resp.sendRedirect(req.getContextPath() + "/quiz?courseId=" + q.getCourseId());
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    private void createQuiz(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int courseId = Integer.parseInt(req.getParameter("courseId"));
        QuizDTO quiz = new QuizDTO();
        quiz.setCourseId(courseId);
        quiz.setTitle(req.getParameter("title"));
        quiz.setDescription(req.getParameter("description"));
        quiz.setTimeLimitMinutes(Integer.parseInt(req.getParameter("timeLimitMinutes")));
        quiz.setPassPercentage(Integer.parseInt(req.getParameter("passPercentage")));
        quizDAO.saveQuiz(quiz);

        String[] texts   = req.getParameterValues("questionText[]");
        String[] optAs   = req.getParameterValues("optionA[]");
        String[] optBs   = req.getParameterValues("optionB[]");
        String[] optCs   = req.getParameterValues("optionC[]");
        String[] optDs   = req.getParameterValues("optionD[]");
        String[] corrects= req.getParameterValues("correctOption[]");
        String[] marks   = req.getParameterValues("marks[]");

        if (texts != null) {
            for (int i = 0; i < texts.length; i++) {
                QuizQuestionDTO q = new QuizQuestionDTO();
                q.setQuizId(quiz.getId());
                q.setQuestionText(texts[i]);
                q.setOptionA(optAs[i]);
                q.setOptionB(optBs[i]);
                q.setOptionC(optCs[i]);
                q.setOptionD(optDs[i]);
                if (corrects[i] != null && !corrects[i].isEmpty()) q.setCorrectOption(corrects[i].charAt(0));
                q.setMarks(Integer.parseInt(marks[i]));
                quizDAO.saveQuestion(q);
            }
        }

        // Notify enrolled students
        CourseDTO course = courseDAO.findById(courseId);
        List<EnrollmentDTO> enrollments = enrollmentDAO.findByCourse(courseId);
        for (EnrollmentDTO e : enrollments) {
            UserDTO student = userDAO.findById(e.getStudentId());
            if (student == null) continue;
            NotificationDTO notif = new NotificationDTO();
            notif.setUserId(student.getId());
            notif.setMessage("New quiz posted in \"" + course.getTitle() + "\": " + quiz.getTitle());
            notificationDAO.save(notif);
            new Thread(() -> EmailUtil.sendNewQuizNotice(
                student.getEmail(), student.getFullName(), course.getTitle(), quiz.getTitle())).start();
        }

        resp.sendRedirect(req.getContextPath() + "/quiz?courseId=" + courseId);
    }

    private void submitQuiz(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        UserDTO student = SessionUtil.getLoggedUser(req);
        int quizId = Integer.parseInt(req.getParameter("quizId"));
        QuizDTO quiz = quizDAO.findQuizById(quizId);
        List<QuizQuestionDTO> questions = quizDAO.findQuestionsByQuiz(quizId);

        int totalMarks = 0, earnedMarks = 0;
        for (QuizQuestionDTO q : questions) {
            totalMarks += q.getMarks();
            String ans = req.getParameter("q_" + q.getId());
            if (ans != null && !ans.isEmpty() && ans.charAt(0) == q.getCorrectOption()) {
                earnedMarks += q.getMarks();
            }
        }

        BigDecimal score = totalMarks == 0 ? BigDecimal.ZERO :
            new BigDecimal(earnedMarks * 100.0 / totalMarks).setScale(2, RoundingMode.HALF_UP);
        boolean passed = score.compareTo(new BigDecimal(quiz.getPassPercentage())) >= 0;

        QuizAttemptDTO attempt = new QuizAttemptDTO();
        attempt.setQuizId(quizId);
        attempt.setStudentId(student.getId());
        attempt.setScore(score);
        attempt.setPassed(passed);
        int attemptId = quizDAO.saveAttempt(attempt);

        for (QuizQuestionDTO q : questions) {
            String ans = req.getParameter("q_" + q.getId());
            char selected = (ans != null && !ans.isEmpty()) ? ans.charAt(0) : ' ';
            quizDAO.saveAnswer(attemptId, q.getId(), selected);
        }

        // Notification
        NotificationDTO notif = new NotificationDTO();
        notif.setUserId(student.getId());
        notif.setMessage("Quiz \"" + quiz.getTitle() + "\" result: " + score + "% - " + (passed ? "PASSED" : "FAILED"));
        notificationDAO.save(notif);

        final String scoreStr = score.toPlainString();
        final boolean passedFinal = passed;
        new Thread(() -> EmailUtil.sendQuizResult(
            student.getEmail(), student.getFullName(), quiz.getTitle(), scoreStr, passedFinal)).start();

        resp.sendRedirect(req.getContextPath() + "/quiz?action=result&attemptId=" + attemptId);
    }
}
